---
title: "{{ .Title }}"
date: {{ .Date.Format "2006-01-02" }}
{{- with .Params.tags }}
tags: [{{ range $i, $t := . }}{{ if $i }}, {{ end }}"{{ $t }}"{{ end }}]
{{- end }}
{{- with .Params.categories }}
categories: [{{ range $i, $c := . }}{{ if $i }}, {{ end }}"{{ $c }}"{{ end }}]
{{- end }}
{{- with .Params.summary }}
summary: "{{ . }}"
{{- end }}
{{- with .Params.series }}
series: [{{ range $i, $s := . }}{{ if $i }}, {{ end }}"{{ $s }}"{{ end }}]
{{- end }}
---

{{ .RawContent }}
