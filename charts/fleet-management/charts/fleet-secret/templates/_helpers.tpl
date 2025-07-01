{{/*
Fleet Secret specific helpers that use the fleet-common library
*/}}

{{/*
Expand the name of the chart using fleet-common library.
*/}}
{{- define "fleet-secret.name" -}}
{{- include "fleet-common.name" . }}
{{- end }}

{{/*
Create a default fully qualified app name using fleet-common library.
*/}}
{{- define "fleet-secret.fullname" -}}
{{- include "fleet-common.fullname" . }}
{{- end }}

{{/*
Create chart name and version using fleet-common library.
*/}}
{{- define "fleet-secret.chart" -}}
{{- include "fleet-common.chart" . }}
{{- end }}

{{/*
Common labels using fleet-common library.
*/}}
{{- define "fleet-secret.labels" -}}
{{ include "fleet-common.labels" . }}
{{- end }}

{{/*
Selector labels using fleet-common library.
*/}}
{{- define "fleet-secret.selectorLabels" -}}
{{ include "fleet-common.selectorLabels" . }}
{{- end }}

{{/*
Create the name of the service account to use from fleet-common library.
*/}}
{{- define "fleet-secret.serviceAccountName" -}}
{{ include "fleet-common.serviceAccountName" . }}
{{- end }}
