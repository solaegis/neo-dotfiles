{{/* Return true if profile name is allowed on this machine. */}}
{{- define "profileAllowed" -}}
{{- $name := .name -}}
{{- $ctx := .context | default "personal" -}}
{{- $enabled := .enabledWorkProfiles | default list -}}
{{- $primarySlug := "" -}}
{{- if hasPrefix $ctx "work-" -}}
{{- $primarySlug = trimPrefix $ctx "work-" -}}
{{- end -}}
{{- if eq $name "personal" -}}true
{{- else if eq $primarySlug $name -}}true
{{- else if has $enabled $name -}}true
{{- else -}}false
{{- end -}}
{{- end -}}

{{/* Default SSH key slug for primary context. */}}
{{- define "defaultSSHKey" -}}
{{- $ctx := .context | default "personal" -}}
{{- if eq $ctx "personal" -}}
neo
{{- else if hasPrefix $ctx "work-" -}}
{{- trimPrefix $ctx "work-" -}}
{{- else -}}neo
{{- end -}}
{{- end -}}

{{/* True when work tooling (docker/kubectl) should load. */}}
{{- define "workTooling" -}}
{{- $ctx := .context | default "personal" -}}
{{- if hasPrefix $ctx "work-" -}}true
{{- else if .enabledWorkProfiles | default list | len | lt 0 -}}true
{{- else -}}false
{{- end -}}
{{- end -}}
