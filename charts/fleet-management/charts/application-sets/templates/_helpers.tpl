{{/*
Application Sets specific helpers that use the fleet-common library
*/}}

{{/*
Expand the name of the chart using fleet-common library.
*/}}
{{- define "application-sets.name" -}}
{{- include "fleet-common.name" . }}
{{- end }}

{{/*
Generate a fully qualified app name using fleet-common library.
*/}}
{{- define "application-sets.fullname" -}}
{{- include "fleet-common.fullname" . }}
{{- end }}

{{/*
Create chart name and version using fleet-common library.
*/}}
{{- define "application-sets.chart" -}}
{{- include "fleet-common.chart" . }}
{{- end }}

{{/*
Common labels for the ApplicationSet using fleet-common library.
*/}}
{{- define "application-sets.labels" -}}
{{ include "fleet-common.labels" . }}
{{- end }}

{{/*
Common annotations using fleet-common library with application-sets specific annotations.
*/}}
{{- define "application-sets.annotations" -}}
{{ include "fleet-common.annotations" . }}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations }}
{{- end }}
{{- end }}
