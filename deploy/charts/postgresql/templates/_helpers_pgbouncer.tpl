{{/* vim: set filetype=mustache: */}}

{{- define "pgbouncer.name" -}}
{{- include "postgresql.name" . -}}-pgbouncer
{{- end -}}

{{- define "pgbouncer.fullname" -}}
{{- include "postgresql.fullname" . -}}-pgbouncer
{{- end -}}
