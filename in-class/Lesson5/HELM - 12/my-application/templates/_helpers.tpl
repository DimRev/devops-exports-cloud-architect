{{- define "my-application.name" -}}
{{- if .Chart -}}
{{- if .Chart.Name -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
"my-application"
{{- end -}}
{{- else -}}
"my-application"
{{- end -}}
{{- end }}

{{- define "my-application.fullname" -}}
{{- if .Chart -}}
{{- include "my-application.name" . }}-{{ .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else -}}
"my-application-fullname"
{{- end -}}
{{- end }}

{{- define "my-application.chart" -}}
{{- if and .Chart .Chart.Name .Chart.Version -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | trunc 63 | trimSuffix "-" -}}
{{- else -}}
"my-application-chart"
{{- end -}}
{{- end }}

{{- define "my-application.labels" -}}
{{- $labels := dict "app.kubernetes.io/name" (include "my-application.name" .) "helm.sh/chart" (include "my-application.chart" .) -}}
{{- if .Chart.AppVersion }}
{{- $_ := set $labels "app.kubernetes.io/version" .Chart.AppVersion -}}
{{- end -}}
{{- if .Chart.Version }}
{{- $_ := set $labels "helm.sh/chart" .Chart.Version -}}
{{- end -}}
{{- $labels | toYaml | nindent 4 -}}
{{- end }}