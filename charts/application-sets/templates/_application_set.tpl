{{/*
Template to generate additional resources configuration
*/}}
{{- define "application-sets.additionalResources" -}}
{{- $chartName := .chartName -}}
{{- $chartConfig := .chartConfig -}}
{{- $valueFiles := .valueFiles -}}
{{- $additionalResourcesType := .additionalResourcesType -}}
{{- $additionalResourcesPath := .path -}}
{{- $values := .values -}}
{{- if $chartConfig.additionalResources.path }}
- repoURL: {{ $values.repoURLGit | squote }}
  targetRevision: {{ $values.repoURLGitRevision | squote }}
  path: {{- if eq $additionalResourcesType "manifests" }}
    '{{ $values.repoURLGitBasePath }}{{ if $values.useValuesFilePrefix }}{{ $values.valuesFilePrefix }}{{ end }}clusters/{{`{{.nameNormalized}}`}}/{{ $chartConfig.additionalResources.manifestPath }}'
  {{- else }}
    {{ $chartConfig.additionalResources.path | squote }}
  {{- end}}
{{- end }}
{{- if $chartConfig.additionalResources.chart }}
- repoURL: '{{$chartConfig.additionalResources.repoURL}}'
  chart: '{{$chartConfig.additionalResources.chart}}'
  targetRevision: '{{$chartConfig.additionalResources.chartVersion }}'
{{- end }}
{{- if $chartConfig.additionalResources.helm }}
  helm:
    releaseName: '{{`{{ .name }}`}}-{{ $chartConfig.additionalResources.helm.releaseName }}'
    {{- if $chartConfig.additionalResources.helm.valuesObject }}
    valuesObject:
    {{- $chartConfig.additionalResources.helm.valuesObject | toYaml | nindent 6 }}
    {{- end }}
    ignoreMissingValueFiles: true
    valueFiles:
    {{- include "application-sets.valueFiles" (dict 
      "nameNormalize" $chartName 
      "valueFiles" $valueFiles 
      "values" $values 
      "chartType" $additionalResourcesType) | nindent 6 }}
{{- end }}
{{- end }}


{{/*
Define the values path for reusability
*/}}
{{- define "application-sets.valueFiles" -}}
{{- $nameNormalize := .nameNormalize -}}
{{- $chartConfig := .chartConfig -}}
{{- $valueFiles := .valueFiles -}}
{{- $chartType := .chartType -}}
{{- $values := .values -}}
{{- $valuesFileName := default "values.yaml" $chartConfig.valuesFileName -}}
{{- $applicationSetGroup := default "" $values.applicationSetGroup -}}

{{- with .valueFiles }}
{{- range . }}
{{/* Path with applicationSetGroup if available */}}
- $values/{{$values.repoURLGitBasePath}}
{{- if $values.useValuesFilePrefix -}}/{{$values.valuesFilePrefix}}{{- end -}}/{{.}}
{{- if $applicationSetGroup -}}/{{$applicationSetGroup}}{{- end -}}/{{$nameNormalize}}
{{- if $chartType -}}/{{$chartType}}{{- end -}}
{{- if $chartConfig.valuesFileName -}}/{{$chartConfig.valuesFileName}}
{{- else -}}/values.yaml{{- end -}}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate valuesObject section with merged common labels and annotations
Usage: {{ include "application-sets.valuesObject" (dict "commonLabels" .Values.commonLabels "commonAnnotations" .Values.commonAnnotations "chartConfig" $chartConfig) }}
*/}}
{{- define "application-sets.valuesObject" -}}
{{- $mergedLabels := include "application-sets.mergeCommon" (dict "global" .commonLabels "chart" .chartConfig.commonLabels) | fromYaml }}
{{- $mergedAnnotations := include "application-sets.mergeCommon" (dict "global" .commonAnnotations "chart" .chartConfig.commonAnnotations) | fromYaml }}
{{- if or .chartConfig.valuesObject $mergedLabels $mergedAnnotations }}
          valuesObject:
{{- if $mergedLabels }}
            commonLabels:
              {{- toYaml $mergedLabels | nindent 14 }}
{{- end }}
{{- if $mergedAnnotations }}
            commonAnnotations:
              {{- toYaml $mergedAnnotations | nindent 14 }}
{{- end }}
{{- if .chartConfig.valuesObject }}
          {{- .chartConfig.valuesObject | toYaml | nindent 12 }}
{{- end }}
{{- end }}
{{- end }}