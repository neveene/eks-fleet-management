{{/*
Generate bootstrap ApplicationSet for a given group (addons, resources, monitoring)
Usage: {{ include "fleet-common.bootstrapApplicationSet" (dict "context" . "group" "addons" "config" .Values.bootstrap.groups.addons) }}
*/}}
{{- define "fleet-common.bootstrapApplicationSet" -}}
{{- $useSelectors := (default .context.Values.bootstrap.global.useSelectors .config.useSelectors) -}}
{{- $useVersionSelectors := (default .context.Values.bootstrap.global.useVersionSelectors .config.useVersionSelectors) -}}
{{- $globalSelectors := (default .context.Values.bootstrap.global.globalSelectors .config.globalSelectors) -}}
{{- $repoNames := .config.repoNames -}}
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-{{ .group }}
  namespace: {{ .context.Values.argocd.namespace | default "argocd" }}
  labels:
    {{- include "fleet-common.labels" .context | nindent 4 }}
    fleet.io/group: {{ .group }}
spec:
  syncPolicy:
    preserveResourcesOnDeletion: {{ if hasKey .config "preserveResourcesOnDeletion" }}{{ .config.preserveResourcesOnDeletion }}{{ else }}{{ .context.Values.bootstrap.global.preserveResourcesOnDeletion | default false }}{{ end }}
  goTemplate: true
  goTemplateOptions:
    - missingkey=error
  generators:
    {{- include "fleet-common.matrixGenerator" (dict "context" .context "group" .group "config" .config) | nindent 2 }}

  ###################################################
  #base template (everything common)
  ###################################################
  template:
    metadata:
      name: 'cluster-{{ .group }}-{{`{{.name}}`}}-{{`{{.type | lower }}`}}'
    spec:
      project: {{ if hasKey .config "project" }}{{ .config.project }}{{ else }}{{ .context.Values.bootstrap.global.project | default "default" }}{{ end }}
      destination:
        namespace: {{ .context.Values.argocd.namespace | default "argocd" }}
        name: '{{`{{.name}}`}}'
      syncPolicy:
        automated:
          selfHeal: {{ if and (hasKey .config "syncPolicy") (hasKey .config.syncPolicy "automated") (hasKey .config.syncPolicy.automated "selfHeal") }}{{ .config.syncPolicy.automated.selfHeal }}{{ else }}{{ .context.Values.bootstrap.global.syncPolicy.automated.selfHeal | default false }}{{ end }}
          allowEmpty: {{ if and (hasKey .config "syncPolicy") (hasKey .config.syncPolicy "automated") (hasKey .config.syncPolicy.automated "allowEmpty") }}{{ .config.syncPolicy.automated.allowEmpty }}{{ else }}{{ .context.Values.bootstrap.global.syncPolicy.automated.allowEmpty | default true }}{{ end }}
          prune: {{ if and (hasKey .config "syncPolicy") (hasKey .config.syncPolicy "automated") (hasKey .config.syncPolicy.automated "prune") }}{{ .config.syncPolicy.automated.prune }}{{ else }}{{ .context.Values.bootstrap.global.syncPolicy.automated.prune | default false }}{{ end }}
        retry:
          limit: {{ if and (hasKey .config "syncPolicy") (hasKey .config.syncPolicy "retry") (hasKey .config.syncPolicy.retry "limit") }}{{ .config.syncPolicy.retry.limit }}{{ else }}{{ .context.Values.bootstrap.global.syncPolicy.retry.limit | default 100 }}{{ end }}
        syncOptions:
          - CreateNamespace=true
          - ServerSideApply=true
  ###################################################
  # conditional sources
  ###################################################

  templatePatch: |
  
    {{`{{- $commonValuesPath := printf "%s/%s.yaml" .values.chartName .values.applicationSetGroup  -}}`}}
    {{`{{- $globalValuesPath := .values.globalValuesPath -}}`}}
    {{`{{- $repoNames := list `}}{{ range $repoNames }}"{{ . }}" {{ end }}{{` -}}`}}
    {{`{{- $environment := .metadata.labels.environment -}}`}}

    {{`{{- $tenantPath := "" -}}`}}
    {{`{{- if and (hasKey . "tenant") .tenant -}}`}}
      {{`{{- $tenantPath = printf "%s" .tenant -}}`}}
    {{`{{- else if (index .metadata.labels "tenant") -}}`}}
      {{`{{- $tenantPath = printf "%s" .metadata.labels.tenant -}}`}}
    {{`{{- end -}}`}}

    {{`{{- $clusterName := "" -}}`}}
    {{`{{- if and (hasKey . "clusterName") .clusterName -}}`}}
      {{`{{- $clusterName = .clusterName -}}`}}
    {{`{{- else  -}}`}}
      {{`{{- $clusterName = .name -}}`}}
    {{`{{- end -}}`}}

    {{`{{- $pathPatterns := list
      (printf "%s/defaults" $tenantPath) 
      (printf "%s/environments/%s/defaults" $tenantPath $environment) 
      (printf "%s/environments/%s/clusters/%s" $tenantPath $environment $clusterName) 
    -}}`}}

    spec:
      sources:
      {{`{{- range $repoName := $repoNames }}`}}
        - repoURL: '{{`{{default (index $.metadata.annotations (printf "%s_repo_url" $repoName)) (index $ "repoUrl")}}`}}'
          targetRevision: '{{`{{default (index $.metadata.annotations (printf "%s_repo_revision" $repoName)) (index $ "targetRevision")}}`}}'
          ref: {{`{{$repoName}}`}}Values
      {{`{{- end }}`}}

       {{`{{- if eq .use_helm_repo_path "false" }}`}}
        - repoURL: '{{`{{default .values.chartRepo .chartRepo }}`}}'
          chart: '{{`{{ default .values.chartName .ecrChartName }}`}}'
          targetRevision: '{{`{{.version}}`}}'
      {{`{{- else }}`}}

        - repoURL: '{{`{{ .metadata.annotations.addons_repo_url }}`}}'
          path: '{{`{{ default .values.chartPath (index . "chartPath")}}`}}'
          targetRevision: '{{`{{ default .metadata.annotations.addons_repo_revision (index . "targetRevision")}}`}}'
      {{`{{- end }}`}}

          helm:
            ignoreMissingValueFiles: true
            valuesObject:
              useSelectors: {{ $useSelectors | quote }}
              useVersionSelectors: {{ $useVersionSelectors | quote }}
              applicationSetGroup: {{ .group | quote }}
            # Defining the way to group addons This application set will handly Addons and ACK values
              {{- if or .config.mergeValues .context.Values.bootstrap.global.mergeValues }}
              mergeValues:
                {{- if .config.mergeValues }}
                {{- toYaml .config.mergeValues | nindent 16 }}
                {{- else }}
                {{- toYaml .context.Values.bootstrap.global.mergeValues | nindent 16 }}
                {{- end }}
              {{- end }}
              {{- if or .config.applicationSets .context.Values.bootstrap.global.applicationSets }}
              {{- $appSets := dict }}
              {{- if .config.applicationSets }}
                {{- $appSets = .config.applicationSets }}
              {{- else }}
                {{- $appSets = .context.Values.bootstrap.global.applicationSets }}
              {{- end }}
              {{- range $key, $value := $appSets }}
              {{ $key }}:
                {{- toYaml $value | nindent 16 }}
              {{- end }}
              {{- end }}
              releaseType: '{{`{{.type | lower }}`}}'
              # If we are using version selector we add the version of the releases on the matchlabels
              {{- if eq $useVersionSelectors true }}
              releases:
                {{.group}}Release: '{{`{{.type | lower}}`}}'
              {{- end }}
              {{- if eq $useSelectors false }}
              globalSelectors:
                {{- toYaml $globalSelectors | nindent 16 }}
              {{- end }}
            # Those are the Value files to read for the Whole group of applications
            valueFiles:
            {{`{{- range $repoName := $repoNames }}`}}
              {{`{{- $repoRef := printf "%sValues" $repoName }}`}}
              - {{`${{$repoRef}}/{{$repoName}}/{{$globalValuesPath}}{{$commonValuesPath}}`}}
              {{`{{- $basePath := default (index $.metadata.annotations (printf "%s_repo_basepath" $repoName)) (index $ (printf "%s_repo_basepath" $repoName)) }}`}}
              {{`{{- range $pattern := $pathPatterns }}`}}
              - {{`${{ $repoRef }}/{{ $basePath }}/{{ $pattern }}/{{ $commonValuesPath }}`}}
              {{`{{- end }}`}}
            {{`{{- end }}`}}
{{- end }}
