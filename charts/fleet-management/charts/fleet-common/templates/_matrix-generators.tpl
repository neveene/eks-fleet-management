{{/*
Standard matrix generator for bootstrap ApplicationSets
Usage: {{ include "fleet-common.matrixGenerator" (dict "context" . "group" "addons" "config" .Values.bootstrap.groups.addons) }}
*/}}
{{- define "fleet-common.matrixGenerator" -}}
- matrix:
    generators:
      - matrix:
          generators:
            - clusters:
                selector:
                  matchLabels:
                    fleet_member: {{ if hasKey .config "fleetMember" }}{{ .config.fleetMember }}{{ else }}{{ .context.Values.bootstrap.global.fleetMember | default "hub-cluster" }}{{ end }}
                    {{- if .config.additionalSelectors }}
                    {{- toYaml .config.additionalSelectors | nindent 20 }}
                    {{- end }}
                values:
                  chartName: {{ if hasKey .config "chartName" }}{{ .config.chartName }}{{ else }}{{ .context.Values.bootstrap.global.chartName | default "application-sets" }}{{ end }}
                  chartRepo: {{ .context.Values.chartRepo | quote }}
                  chartPath: {{ if hasKey .config "chartPath" }}{{ .config.chartPath | quote }}{{ else }}{{ .context.Values.bootstrap.global.chartPath | default "charts/application-sets" | quote }}{{ end }}
                  applicationSetGroup: {{ .group | quote }}
                  groupRelease: '{{`{{default "" (index .metadata.labels "`}}{{ .group }}{{`Release")}}`}}'
                  useSelectors: {{ if hasKey .config "useSelectors" }}{{ .config.useSelectors | quote }}{{ else }}{{ .context.Values.bootstrap.global.useSelectors | default "false" | quote }}{{ end }}
                  useVersionSelectors: {{ if hasKey .config "useVersionSelectors" }}{{ .config.useVersionSelectors | quote }}{{ else }}{{ .context.Values.bootstrap.global.useVersionSelectors | default "true" | quote }}{{ end }}
                  globalValuesPath: {{ (default .config.globalValuesPath .context.Values.bootstrap.global.globalValuesPath) | quote }}
            - git:
                repoURL: '{{`{{ .metadata.annotations.fleet_repo_url }}`}}'
                revision: '{{`{{ .metadata.annotations.fleet_repo_revision }}`}}'
                files:
                  - path: "{{`{{ .metadata.annotations.fleet_repo_basepath }}`}}/{{ if hasKey .config "versionsPath" }}{{ .config.versionsPath }}{{ else }}{{ .context.Values.bootstrap.global.versionsPath | default "versions/applicationSets.yaml" }}{{ end }}"
      - list:
          elementsYaml: |
            {{`{{- $releaseTypes := index .releases .values.applicationSetGroup | toJson | fromJson -}}`}}
            {{`{{- $result := list -}}`}}
            {{`{{- $defaultVersion := dict -}}`}}
            {{`{{- /* Defining the Default Version in case we need to fall back */ -}}`}}
            {{`{{- range $releaseType := $releaseTypes -}}`}}
              {{`{{- if eq $releaseType.type "default" -}}`}}
                {{`{{- $defaultVersion = $releaseType -}}`}}
              {{`{{- end -}}`}}
            {{`{{- end -}}`}}
            {{`{{- /* We look for the defined releases */ -}}`}}
            {{`{{- range $releaseType := $releaseTypes -}}`}}
                {{`{{- $result = append $result $releaseType -}}`}}
            {{`{{- end -}}`}}
            {{`{{- /* If no releases were selected, use default */ -}}`}}
            {{`{{- if eq (len $result) 0 -}}`}}
              {{`{{- $result = append $result $defaultVersion -}}`}}
            {{`{{- end -}}`}}
            {{`{{ $result | toJson }}`}}
{{- end }}

{{/*
Simple cluster generator for basic ApplicationSets
Usage: {{ include "fleet-common.clusterGenerator" (dict "context" . "config" .Values.someConfig) }}
*/}}
{{- define "fleet-common.clusterGenerator" -}}
- clusters:
    selector:
      matchLabels:
        {{- if .config.selector }}
        {{- toYaml .config.selector | nindent 8 }}
        {{- else }}
        fleet_member: {{ .config.fleetMember | default "hub-cluster" }}
        {{- end }}
    {{- if .config.values }}
    values:
      {{- toYaml .config.values | nindent 6 }}
    {{- end }}
{{- end }}

{{/*
Git generator for file-based configurations
Usage: {{ include "fleet-common.gitGenerator" (dict "context" . "config" .Values.gitConfig) }}
*/}}
{{- define "fleet-common.gitGenerator" -}}
- git:
    repoURL: {{ .config.repoURL | default "'{{ .metadata.annotations.fleet_repo_url }}'" }}
    revision: {{ .config.revision | default "'{{ .metadata.annotations.fleet_repo_revision }}'" }}
    {{- if .config.files }}
    files:
      {{- range .config.files }}
      - path: {{ . | quote }}
      {{- end }}
    {{- end }}
    {{- if .config.directories }}
    directories:
      {{- range .config.directories }}
      - path: {{ . | quote }}
      {{- end }}
    {{- end }}
{{- end }}
