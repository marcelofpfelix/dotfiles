{{.method}} {{.ruri}} SIP/2.0
Via: SIP/2.0/{{.viaproto}} {{.viaaddr}}{{.rport}};branch=z9hG4bKSG.{{.viabranch}}
From: {{if .fromuri}}{{.fromuri}}{{else}}{{if .fname}}"{{.fname}}" {{end}}<sip:{{if .fuser}}{{.fuser}}@{{end}}{{.fdomain}}>{{end}};tag={{.fromtag}}
To: {{if .touri}}{{.touri}}{{else}}{{if .tname}}"{{.tname}}" {{end}}<sip:{{if .tuser}}{{.tuser}}@{{end}}{{.tdomain}}>{{end}}
Call-ID: {{.callid}}
CSeq: {{.cseqnum}} {{.method}}
{{if .subject}}Subject: {{.subject}}{{else}}$rmeol{{end}}
{{if .date}}Date: {{.date}}{{else}}$rmeol{{end}}
{{if .contacturi}}Contact: {{.contacturi}}{{if .contactparams}};{{.contactparams}}{{end}}{{else}}$rmeol{{end}}
{{if .expires}}Expires: {{.expires}}{{else}}$rmeol{{end}}
{{if .useragent}}User-Agent: {{.useragent}}{{else}}$rmeol{{end}}
Content-Length: 0
