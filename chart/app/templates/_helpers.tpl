{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "chart.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chart.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Release.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Release.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
helm.sh/chart: {{ include "chart.chart" . }}
{{ include "chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "chart.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Gateway API: hostnames of the HTTPRoute / ListenerSet / Certificate (JSON list).
Defaults to [default.host].
*/}}
{{- define "chart.httpRoute.hostnames" -}}
{{- $hosts := .Values.httpRoute.hostnames | default (list .Values.default.host) -}}
{{- toJson $hosts -}}
{{- end -}}

{{/*
Gateway API: TLS secret of the ListenerSet listeners. Defaults to <fullname>-tls.
*/}}
{{- define "chart.listenerSet.secretName" -}}
{{- .Values.httpRoute.listenerSet.secretName | default (printf "%s-tls" (include "chart.fullname" .)) -}}
{{- end -}}

{{/*
Gateway API: listener name for a hostname, e.g. https-www-example-com,
https-wildcard-apps-example-com. Args: (list protocol hostname)
*/}}
{{- define "chart.listenerSet.listenerName" -}}
{{- $protocol := index . 0 | lower -}}
{{- $host := index . 1 | replace "*" "wildcard" | replace "." "-" | lower -}}
{{- printf "%s-%s" $protocol $host | trunc 253 | trimSuffix "-" -}}
{{- end -}}

{{/*
Gateway API: true when the ListenerSet is rendered.
*/}}
{{- define "chart.listenerSet.enabled" -}}
{{- if and .Values.httpRoute .Values.httpRoute.enabled .Values.httpRoute.listenerSet .Values.httpRoute.listenerSet.enabled -}}true{{- end -}}
{{- end -}}
