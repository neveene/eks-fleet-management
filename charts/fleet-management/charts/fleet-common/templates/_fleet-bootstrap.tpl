# {{/*
# Fleet member registration ApplicationSet
# Usage: {{ include "fleet-common.fleetRegistration" . }}
# */}}
# {{- define "fleet-common.fleetRegistration" -}}
# apiVersion: argoproj.io/v1alpha1
# kind: ApplicationSet
# metadata:
#   name: {{ .Values.fleetBootstrap.registrationName | default "fleet-registration" }}
#   namespace: {{ .Values.argocd.namespace | default "argocd" }}
#   labels:
#     {{- include "fleet-common.labels" . | nindent 4 }}
#     fleet.io/component: registration
# spec:
#   goTemplate: true
#   syncPolicy:
#     preserveResourcesOnDeletion: {{ .Values.fleetBootstrap.preserveResourcesOnDeletion | default true }}
#   generators:
#     {{- include "fleet-common.clusterGenerator" (dict "context" . "config" .Values.fleetBootstrap.clusterSelector) | nindent 2 }}
#   template:
#     metadata:
#       name: {{ .Values.fleetBootstrap.applicationName | default "fleet" }}
#     spec:
#       project: {{ .Values.fleetBootstrap.project | default "default" }}
#       sources:
#         - repoURL: 'test'
#           targetRevision: 'test'
#           ref: values
#         - repoURL: 'test'
#           path: charts/fleet-management
#           targetRevision: 'test'
#           helm:
#             releaseName: '{{.name}}'
#             valuesObject:
#               bootstrap: true
#               fl
#             ignoreMissingValueFiles: true
#       destination:
#         namespace: {{ .Values.argocd.namespace | default "argocd" }}
#         name: '{{`{{.name}}`}}'
#       syncPolicy:
#         {{- if .Values.fleetBootstrap.syncPolicy }}
#         {{- toYaml .Values.fleetBootstrap.syncPolicy | nindent 8 }}
#         {{- else }}
#         automated: {}
#         {{- end }}
# {{- end }}

{{/*
Fleet hub external secrets ApplicationSet
Usage: {{ include "fleet-common.fleetSecrets" . }}
*/}}
{{- define "fleet-common.fleetSecrets" -}}
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: {{ .Values.fleetBootstrap.secrets.name | default "fleet-hub-secrets" }}
  namespace: {{ .Values.argocd.namespace | default "argocd" }}
  labels:
    {{- include "fleet-common.labels" . | nindent 4 }}
    fleet.io/component: secrets
spec:
  goTemplate: true
  syncPolicy:
    preserveResourcesOnDeletion: {{ .Values.fleetBootstrap.secrets.preserveResourcesOnDeletion | default true }}
  generators:
    {{- include "fleet-common.clusterGenerator" (dict "context" . "config" .Values.fleetBootstrap.secrets.clusterSelector) | nindent 2 }}
  template:
    metadata:
      name: {{ .Values.fleetBootstrap.secrets.applicationName | default "fleet-secrets" }}
    spec:
      project: {{ .Values.fleetBootstrap.secrets.project | default "default" }}
      source:
        repoURL: '{{`{{.metadata.annotations.fleet_repo_url}}`}}'
        path: '{{`{{.metadata.annotations.fleet_repo_basepath}}`}}/{{ .Values.fleetBootstrap.secrets.sourcePath | default "fleet-bootstrap" }}'
        targetRevision: '{{`{{.metadata.annotations.fleet_repo_revision}}`}}'
        helm:
          releaseName: {{ .Values.fleetBootstrap.secrets.releaseName | default "fleet-secrets" }}
          {{- if .Values.fleetBootstrap.secrets.valueFiles }}
          valueFiles:
            {{- range .Values.fleetBootstrap.secrets.valueFiles }}
            - {{ . }}
            {{- end }}
          {{- end }}
          {{- if .Values.fleetBootstrap.secrets.values }}
          values: |
            {{- toYaml .Values.fleetBootstrap.secrets.values | nindent 12 }}
          {{- end }}
      destination:
        namespace: {{ .Values.fleetBootstrap.secrets.namespace | default "platform-system" }}
        name: '{{`{{.name}}`}}'
      syncPolicy:
        {{- if .Values.fleetBootstrap.secrets.syncPolicy }}
        {{- toYaml .Values.fleetBootstrap.secrets.syncPolicy | nindent 8 }}
        {{- else }}
        automated:
          selfHeal: true
          prune: true
        {{- end }}
{{- end }}

# {{/*
# Fleet member bootstrap ApplicationSet
# Usage: {{ include "fleet-common.fleetMemberBootstrap" . }}
# */}}
# {{- define "fleet-common.fleetMemberBootstrap" -}}
# apiVersion: argoproj.io/v1alpha1
# kind: ApplicationSet
# metadata:
#   name: {{ .Values.fleetBootstrap.memberBootstrap.name | default "fleet-members-bootstrap" }}
#   namespace: {{ .Values.argocd.namespace | default "argocd" }}
#   labels:
#     {{- include "fleet-common.labels" . | nindent 4 }}
#     fleet.io/component: member-bootstrap
# spec:
#   goTemplate: true
#   syncPolicy:
#     preserveResourcesOnDeletion: {{ .Values.fleetBootstrap.memberBootstrap.preserveResourcesOnDeletion | default true }}
#   generators:
#     {{- include "fleet-common.clusterGenerator" (dict "context" . "config" .Values.fleetBootstrap.memberBootstrap.clusterSelector) | nindent 2 }}
#   template:
#     metadata:
#       name: 'fleet-member-bootstrap-{{`{{.name}}`}}'
#     spec:
#       project: {{ .Values.fleetBootstrap.memberBootstrap.project | default "default" }}
#       source:
#         repoURL: '{{`{{.metadata.annotations.fleet_repo_url}}`}}'
#         path: '{{`{{.metadata.annotations.fleet_repo_basepath}}`}}/{{ .Values.fleetBootstrap.memberBootstrap.sourcePath | default "fleet-bootstrap/members-application-sets" }}'
#         targetRevision: '{{`{{.metadata.annotations.fleet_repo_revision}}`}}'
#         directory:
#           recurse: {{ .Values.fleetBootstrap.memberBootstrap.directory.recurse | default true }}
#       destination:
#         namespace: {{ .Values.argocd.namespace | default "argocd" }}
#         name: '{{`{{.name}}`}}'
#       syncPolicy:
#         {{- if .Values.fleetBootstrap.memberBootstrap.syncPolicy }}
#         {{- toYaml .Values.fleetBootstrap.memberBootstrap.syncPolicy | nindent 8 }}
#         {{- else }}
#         automated:
#           selfHeal: true
#           prune: true
#         {{- end }}
# {{- end }}
