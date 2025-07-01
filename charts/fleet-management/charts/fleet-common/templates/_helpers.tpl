{{/*
Common Fleet Management Library Functions
*/}}

{{/*
Boolean coalesce - returns the first defined boolean value, treating false as valid
Usage: {{ include "fleet-common.boolCoalesce" (list .config.preserveResourcesOnDeletion .context.Values.argocd.preserveResourcesOnDeletion false) }}
*/}}
{{- define "fleet-common.boolCoalesce" -}}
{{- $values := . -}}
{{- range $values -}}
  {{- if not (eq . nil) -}}
    {{- . -}}
    {{- break -}}
  {{- end -}}
{{- end -}}
{{- end }}

{{/*
Get value with fallback chain - handles any type including booleans
Usage: {{ include "fleet-common.getValue" (dict "values" (list .config.someValue .global.someValue "default") "context" .) }}
*/}}
{{- define "fleet-common.getValue" -}}
{{- $values := .values -}}
{{- range $values -}}
  {{- if not (eq . nil) -}}
    {{- . -}}
    {{- break -}}
  {{- end -}}
{{- end -}}
{{- end }}

{{/*
Check if a key exists in a nested path
Usage: {{ include "fleet-common.hasNestedKey" (dict "obj" .Values "path" "bootstrap.groups.addons.enabled") }}
*/}}
{{- define "fleet-common.hasNestedKey" -}}
{{- $obj := .obj -}}
{{- $path := .path -}}
{{- $keys := splitList "." $path -}}
{{- $current := $obj -}}
{{- $exists := true -}}
{{- range $keys -}}
  {{- if and $exists (hasKey $current .) -}}
    {{- $current = index $current . -}}
  {{- else -}}
    {{- $exists = false -}}
  {{- end -}}
{{- end -}}
{{- $exists -}}
{{- end }}

{{/*
Get nested value with path
Usage: {{ include "fleet-common.getNestedValue" (dict "obj" .Values "path" "bootstrap.groups.addons.enabled") }}
*/}}
{{- define "fleet-common.getNestedValue" -}}
{{- $obj := .obj -}}
{{- $path := .path -}}
{{- $keys := splitList "." $path -}}
{{- $current := $obj -}}
{{- range $keys -}}
  {{- if hasKey $current . -}}
    {{- $current = index $current . -}}
  {{- else -}}
    {{- $current = nil -}}
    {{- break -}}
  {{- end -}}
{{- end -}}
{{- $current -}}
{{- end }}

{{/*
Expand the name of the chart. Defaults to `.Chart.Name` or `nameOverride`.
Usage: {{ include "fleet-common.name" . }}
*/}}
{{- define "fleet-common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate a fully qualified app name.
If `fullnameOverride` is defined, it uses that; otherwise, it constructs the name based on `Release.Name` and chart name.
Usage: {{ include "fleet-common.fullname" . }}
*/}}
{{- define "fleet-common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version, useful for labels.
Usage: {{ include "fleet-common.chart" . }}
*/}}
{{- define "fleet-common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels for fleet management resources.
Usage: {{ include "fleet-common.labels" . }}
*/}}
{{- define "fleet-common.labels" -}}
helm.sh/chart: {{ include "fleet-common.chart" . }}
{{ include "fleet-common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels for fleet management resources.
Usage: {{ include "fleet-common.selectorLabels" . }}
*/}}
{{- define "fleet-common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fleet-common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common annotations for fleet management resources.
Usage: {{ include "fleet-common.annotations" . }}
*/}}
{{- define "fleet-common.annotations" -}}
helm.sh/chart: {{ include "fleet-common.chart" . }}
{{- if .Values.commonAnnotations }}
{{ toYaml .Values.commonAnnotations }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use.
Usage: {{ include "fleet-common.serviceAccountName" . }}
*/}}
{{- define "fleet-common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fleet-common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate namespace name with fallback to Release.Namespace.
Usage: {{ include "fleet-common.namespace" . }}
*/}}
{{- define "fleet-common.namespace" -}}
{{- default .Release.Namespace .Values.namespace }}
{{- end }}

{{/*
Common resource naming with prefix support.
Usage: {{ include "fleet-common.resourceName" (dict "context" . "name" "my-resource") }}
*/}}
{{- define "fleet-common.resourceName" -}}
{{- $fullname := include "fleet-common.fullname" .context }}
{{- if .context.Values.resourcePrefix }}
{{- printf "%s-%s-%s" .context.Values.resourcePrefix $fullname .name }}
{{- else }}
{{- printf "%s-%s" $fullname .name }}
{{- end }}
{{- end }}
