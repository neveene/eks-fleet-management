{{/*
Fleet Management specific helpers that use the fleet-common library
*/}}

{{/*
Expand the name of the chart using fleet-common library.
*/}}
{{- define "fleet-management.name" -}}
{{- include "fleet-common.name" . }}
{{- end }}

{{/*
Create a default fully qualified app name using fleet-common library.
*/}}
{{- define "fleet-management.fullname" -}}
{{- include "fleet-common.fullname" . }}
{{- end }}

{{/*
Create chart name and version using fleet-common library.
*/}}
{{- define "fleet-management.chart" -}}
{{- include "fleet-common.chart" . }}
{{- end }}

{{/*
Common labels using fleet-common library.
*/}}
{{- define "fleet-management.labels" -}}
{{ include "fleet-common.labels" . }}
{{- end }}

{{/*
Selector labels using fleet-common library.
*/}}
{{- define "fleet-management.selectorLabels" -}}
{{ include "fleet-common.selectorLabels" . }}
{{- end }}

{{/*
Create the name of the service account to use from fleet-common library.
*/}}
{{- define "fleet-management.serviceAccountName" -}}
{{ include "fleet-common.serviceAccountName" . }}
{{- end }}
