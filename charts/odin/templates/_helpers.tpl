{{/* ========================================================================
   INFRASTRUCTURE SERVICES HELPERS
   Helper functions for external/internal infrastructure services
   ======================================================================== */}}

{{/* ------------------------------------------------------------------------
   MySQL Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Check if internal Percona MySQL is enabled
*/}}
{{- define "percona-mysql.enabled" -}}
{{- if eq .Values.mysql.external.enabled false }}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/*
Get MySQL master host (external or internal haproxy)
*/}}
{{- define "odin.mysql.master.host" -}}
{{- if .Values.mysql.external.enabled -}}
{{- .Values.mysql.external.master.host -}}
{{- else -}}
{{- printf "%s-haproxy" .Values.mysql.fullnameOverride -}}
{{- end -}}
{{- end -}}

{{/*
Get MySQL slave host (external or internal haproxy)
*/}}
{{- define "odin.mysql.slave.host" -}}
{{- if .Values.mysql.external.enabled -}}
{{- .Values.mysql.external.slave.host -}}
{{- else -}}
{{- printf "%s-haproxy" .Values.mysql.fullnameOverride -}}
{{- end -}}
{{- end -}}

{{/*
Get MySQL username
*/}}
{{- define "odin.mysql.username" -}}
{{- if .Values.mysql.external.enabled -}}
{{- .Values.mysql.external.username -}}
{{- else -}}
{{- "root" -}}
{{- end -}}
{{- end -}}

{{/*
Get MySQL password
*/}}
{{- define "odin.mysql.password" -}}
{{- if .Values.mysql.external.enabled -}}
{{- .Values.mysql.external.password -}}
{{- else -}}
$(root)
{{- end -}}
{{- end -}}

{{/* ------------------------------------------------------------------------
   Redis Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Check if internal Redis is enabled
*/}}
{{- define "redis.internal.enabled" -}}
{{- if eq .Values.redis.external.enabled false }}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/*
Get Redis host (external or internal master)
*/}}
{{- define "odin.redis.host" -}}
{{- if .Values.redis.external.enabled -}}
{{- .Values.redis.external.host -}}
{{- else -}}
{{- printf "%s-master.%s.svc.cluster.local" .Values.redis.fullnameOverride .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Get Redis port
*/}}
{{- define "odin.redis.port" -}}
{{- if .Values.redis.external.enabled -}}
{{- .Values.redis.external.port -}}
{{- else -}}
{{- 6379 -}}
{{- end -}}
{{- end -}}

{{/*
Get Redis password
*/}}
{{- define "odin.redis.password" -}}
{{- if .Values.redis.external.enabled -}}
{{- .Values.redis.external.password -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Get Redis database number
*/}}
{{- define "odin.redis.database" -}}
{{- if .Values.redis.external.enabled -}}
{{- .Values.redis.external.database -}}
{{- else -}}
{{- 0 -}}
{{- end -}}
{{- end -}}

{{/*
Build complete Redis connection URL
*/}}
{{- define "odin.redis.url" -}}
{{- $host := include "odin.redis.host" . -}}
{{- $port := include "odin.redis.port" . -}}
{{- $password := include "odin.redis.password" . -}}
{{- $database := include "odin.redis.database" . -}}
{{- if $password -}}
{{- printf "redis://:%s@%s:%s/%s" $password $host $port $database -}}
{{- else -}}
{{- printf "redis://%s:%s/%s" $host $port $database -}}
{{- end -}}
{{- end -}}

{{/* ------------------------------------------------------------------------
   Elasticsearch Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Check if internal Elasticsearch is enabled
*/}}
{{- define "elasticsearch.internal.enabled" -}}
{{- if eq .Values.elasticsearch.external.enabled false }}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/*
Get Elasticsearch host (external or internal cluster service)
*/}}
{{- define "odin.elasticsearch.host" -}}
{{- if .Values.elasticsearch.external.enabled -}}
{{- .Values.elasticsearch.external.host -}}
{{- else }}
{{ printf "%s.%s.svc.cluster.local" .Values.elasticsearch.fullnameOverride .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Get Elasticsearch username
*/}}
{{- define "odin.elasticsearch.username" -}}
{{- if .Values.elasticsearch.external.enabled -}}
{{ .Values.elasticsearch.external.username }}
{{- else -}}
{{ print "elastic" }}
{{- end }}
{{- end }}

{{/*
Get Elasticsearch password
*/}}
{{- define "odin.elasticsearch.password" -}}
{{- if .Values.elasticsearch.external.enabled -}}
{{- .Values.elasticsearch.external.password -}}
{{- else }}
{{ .Values.elasticsearch.security.elasticPassword }}
{{- end }}
{{- end }}

{{/*
Get Elasticsearch port
*/}}
{{- define "odin.elasticsearch.port" -}}
{{- if .Values.elasticsearch.external.enabled -}}
{{- .Values.elasticsearch.external.port -}}
{{- else -}}
{{- 9200 -}}
{{- end -}}
{{- end -}}

{{/* ------------------------------------------------------------------------
   MinIO / S3 Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Get MinIO S3 endpoint URL (internal cluster service)
*/}}
{{- define "odin.s3.endpointUrl" -}}
{{- printf "http://%s.%s.svc.cluster.local:9000" .Values.minio.fullnameOverride .Release.Namespace -}}
{{- end -}}

{{/*
Get MinIO S3 region
*/}}
{{- define "odin.s3.region" -}}
{{- .Values.minio.region -}}
{{- end -}}

{{/*
Get state bucket name from MinIO buckets
Looks for bucket containing "state" in name, falls back to first bucket if none found
*/}}
{{- define "odin.s3.stateBucket" -}}
{{- if not .Values.minio.buckets -}}
{{- fail "No buckets defined in minio.buckets. At least one bucket is required." -}}
{{- end -}}
{{- $stateBucket := "" -}}
{{- range .Values.minio.buckets -}}
{{- if and (contains "state" .name) (not $stateBucket) -}}
{{- $stateBucket = .name -}}
{{- end -}}
{{- end -}}
{{- if $stateBucket -}}
{{- $stateBucket -}}
{{- else -}}
{{- (index .Values.minio.buckets 0).name -}}
{{- end -}}
{{- end -}}

{{/* ------------------------------------------------------------------------
   ElasticMQ / SQS Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Check if internal ElasticMQ (SQS) is enabled
*/}}
{{- define "sqs.internal.enabled" -}}
{{- if eq .Values.elasticMQ.external.enabled false }}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/*
Get ElasticMQ fullname
*/}}
{{- define "elasticmq.fullname" -}}
{{- if .Values.elasticMQ.fullnameOverride -}}
{{ .Values.elasticMQ.fullnameOverride -}}
{{- else -}}
{{ printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}
{{- end -}}

{{/*
Get SQS fullname (wrapper for elasticmq.fullname)
*/}}
{{- define "sqs.fullname" -}}
{{- .Values.elasticMQ.fullnameOverride | default (include "elasticmq.fullname" $) -}}
{{- end -}}

{{/*
Generate ElasticMQ SQS Queue URL (local format)
*/}}
{{- define "elasticmq.sqsQueueUrl" -}}
http://localhost:9324/000000000000/{{ .queue }}
{{- end }}

{{/*
Get Fluent Bit fullname
*/}}
{{- define "fluentbit.fullname" -}}
{{ printf "%s-%s" (include "common.names.fullname" . ) "fluentbit" }}
{{- end -}}

{{/*
Get ElasticMQ selector/match labels
*/}}
{{- define "elasticmq.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}-elasticmq
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Get ElasticMQ standard labels (includes chart version and app version)
*/}}
{{- define "elasticmq.labels.standard" -}}
{{ include "elasticmq.labels.matchLabels" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}

{{/*
Get SQS endpoint URL
*/}}
{{- define "odin.sqs.endpoint" -}}
http://{{ include "sqs.fullname" . }}:9324
{{- end }}

{{/*
Get SQS request queue URL
*/}}
{{- define "odin.sqs.odinQueueRequestUrl" -}}
{{- if .Values.elasticMQ.external.enabled -}}
{{- .Values.elasticMQ.external.requestQueueUrl -}}
{{- else }}
{{ include "elasticmq.sqsQueueUrl" (dict "queue" "odin-request-queue" "Values" .Values) | quote }}
{{- end }}
{{- end }}

{{/*
Get SQS response queue URL
*/}}
{{- define "odin.sqs.odinQueueResponseUrl" -}}
{{- if .Values.elasticMQ.external.enabled -}}
{{- .Values.elasticMQ.external.responseQueueUrl -}}
{{- else }}
{{ include "elasticmq.sqsQueueUrl" (dict "queue" "odin-response-queue" "Values" .Values) | quote }}
{{- end }}
{{- end }}

{{/* ------------------------------------------------------------------------
   Fluent Bit Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Check if internal Fluent Bit is enabled
*/}}
{{- define "fluentbit.internal.enabled" -}}
{{- if eq .Values.fluentbit.external.enabled false }}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/* ========================================================================
   APPLICATION SERVICES HELPERS
   Helper functions for Odin application services
   ======================================================================== */}}

{{/* ------------------------------------------------------------------------
   Deployer Service Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Get deployer fullname
*/}}
{{- define "deployer.fullname" -}}
{{ printf "%s-%s" (include "common.names.fullname" . ) "deployer" }}
{{- end -}}

{{/*
Get deployer image pull secrets
*/}}
{{- define "deployer.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.deployer.image) "global" .Values.global) }}
{{- end -}}

{{/*
Get deployer image name
*/}}
{{- define "deployer.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.deployer.image "global" .Values.global) }}
{{- end -}}

{{/*
Get deployer selector/match labels
*/}}
{{- define "deployer.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}-deployer
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Get deployer standard labels (includes chart version and app version)
*/}}
{{- define "deployer.labels.standard" -}}
{{ include "deployer.labels.matchLabels" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}

{{/*
Get deployer service account name
*/}}
{{- define "deployer.serviceAccountName" -}}
{{- if .Values.deployer.serviceAccount.create -}}
    {{ default (include "deployer.fullname" .) .Values.deployer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.deployer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Validate and get deployer public key as a single-line string
*/}}
{{- define "deployer.security.auth.publicKey" -}}
{{- $publicKey := (.Values.deployer.security.auth.publicKey | default "") | toString -}}
{{- $clean := $publicKey | replace "\n" "" | replace "\r" "" | trim -}}
{{- if eq $clean "" -}}
{{- fail "deployer.security.auth.publicKey is required but empty" -}}
{{- end -}}
{{- $clean -}}
{{- end -}}

{{/*
Validate and get deployer private key as a single-line string
*/}}
{{- define "deployer.security.auth.privateKey" -}}
{{- $privateKey := (.Values.deployer.security.auth.privateKey | default "") | toString -}}
{{- $clean := $privateKey | replace "\n" "" | replace "\r" "" | trim -}}
{{- if eq $clean "" -}}
{{- fail "deployer.security.auth.privateKey is required but empty" -}}
{{- end -}}
{{- $clean -}}
{{- end -}}

{{/*
Generate deployer environment variables
Includes database, account manager, logstore, and queue configurations
*/}}
{{- define "deployer.envs" -}}
- name: RESOURCES_PATH
  value: /opt/odin-deployer/resources
- name: ODIN_MYSQL_MASTER_HOST
  value: {{ include "odin.mysql.master.host" . | quote }}
- name: ODIN_MYSQL_SLAVE_HOST
  value: {{ include "odin.mysql.slave.host" . | quote }}
- name: ODIN_MYSQL_USERNAME
  value: {{ include "odin.mysql.username" . | quote }}
- name: ODIN_MYSQL_PASSWORD
  value: {{ include "odin.mysql.password" . | quote }}
- name: ODIN_ACCOUNT_MANAGER_HOST
  value: {{ include "accountManager.fullname" . | quote }}
- name: ODIN_ACCOUNT_MANAGER_PORT
  value: "80"
- name: ODIN_LOGSTORE_HOST
  value: {{ include "odin.elasticsearch.host" . | trim }}
- name: ODIN_LOGSTORE_USERNAME
  value: {{ include "odin.elasticsearch.username" . | trim }}
- name: ODIN_LOGSTORE_PASSWORD
  value: {{ include "odin.elasticsearch.password" . | trim }}
- name: ODIN_LOGSTORE_PORT
  value: {{ include "odin.elasticsearch.port" . | quote }}
- name: ODIN_QUEUE_REQUEST_ENDPOINT
  value: {{ include "odin.sqs.endpoint" . | trim }}
- name: ODIN_QUEUE_RESPONSE_ENDPOINT
  value: {{ include "odin.sqs.endpoint" . | trim }}
- name: ODIN_QUEUE_REQUEST_URL
  value: {{ include "odin.sqs.odinQueueRequestUrl" . | trim }}
- name: ODIN_QUEUE_RESPONSE_URL
  value: {{ include "odin.sqs.odinQueueResponseUrl" . | trim }}
- name: ODIN_QUEUE_REQUEST_PROVIDER
  value: sqs
- name: ODIN_QUEUE_REQUEST_REGION
  value: {{ .Values.elasticMQ.aws.region }}
{{- end }}

{{/* ------------------------------------------------------------------------
   Orchestrator Service Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Get orchestrator fullname
*/}}
{{- define "orchestrator.fullname" -}}
{{ printf "%s-%s" (include "common.names.fullname" . ) "orchestrator" }}
{{- end -}}

{{/*
Get orchestrator image pull secrets
*/}}
{{- define "orchestrator.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.orchestrator.image) "global" .Values.global) }}
{{- end -}}

{{/*
Get orchestrator image name
*/}}
{{- define "orchestrator.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.orchestrator.image "global" .Values.global) }}
{{- end -}}

{{/*
Get orchestrator selector/match labels
*/}}
{{- define "orchestrator.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}-orchestrator
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Get orchestrator standard labels (includes chart version and app version)
*/}}
{{- define "orchestrator.labels.standard" -}}
{{ include "orchestrator.labels.matchLabels" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}

{{/*
Get orchestrator service account name
*/}}
{{- define "orchestrator.serviceAccountName" -}}
{{- if .Values.deployer.serviceAccount.create -}}
    {{ default (include "orchestrator.fullname" .) .Values.orchestrator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.deployer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Generate orchestrator environment variables
Includes DSL state (S3), locking (Redis), discovery service, and queue configurations
*/}}
{{- define "orchestrator.envs" -}}
- name: ODIN_DSL_STATE_S3_ENDPOINT
  value: {{ include "odin.s3.endpointUrl" . | quote }}
- name: ODIN_DSL_STATE_S3_BUCKET
  value: {{ include "odin.s3.stateBucket" . | quote }}
- name: ODIN_DSL_STATE_S3_REGION
  value: {{ include "odin.s3.region" . | quote }}
- name: ODIN_DSL_STATE_S3_AWS_ACCESS_KEY_ID
  value: {{ .Values.minio.rootUser | quote }}
- name: ODIN_DSL_STATE_S3_AWS_SECRET_ACCESS_KEY
  value: {{ .Values.minio.rootPassword | quote }}
- name: ODIN_DSL_LOCK_REDIS_HOST
  value: {{ include "odin.redis.host" . | quote }}
- name: ODIN_DSL_LOCK_REDIS_PORT
  value: {{ include "odin.redis.port" . | quote }}
- name: ODIN_DSL_LOCK_REDIS_PASSWORD
  value: {{ include "odin.redis.password" . | quote }}
- name: ODIN_DSL_LOCK_REDIS_DATABASE
  value: {{ include "odin.redis.database" . | quote }}
- name: ODIN_DISCOVERY_URL
  value: {{ include "discoveryService.fullname" . | quote }}
- name: ODIN_DISCOVERY_SERVICE_PORT
  value: "80"
- name: ODIN_QUEUE_REQUEST_ENDPOINT
  value: {{ include "odin.sqs.endpoint" . | trim }}
- name: ODIN_QUEUE_RESPONSE_ENDPOINT
  value: {{ include "odin.sqs.endpoint" . | trim }}
- name: ODIN_QUEUE_REQUEST_URL
  value: {{ include "odin.sqs.odinQueueRequestUrl" . | trim }}
- name: ODIN_QUEUE_RESPONSE_URL
  value: {{ include "odin.sqs.odinQueueResponseUrl" . | trim }}
- name: ODIN_QUEUE_REQUEST_PROVIDER
  value: sqs
- name: ODIN_QUEUE_REQUEST_REGION
  value: {{ .Values.elasticMQ.aws.region }}
{{- end }}

{{/*
Validate orchestrator scaledJob triggers for AWS SQS
Ensures required metadata fields are present when using aws-sqs-queue provider
*/}}
{{- define "orchestrator.validateSQSTriggers" -}}
{{- if eq .Values.orchestrator.scaledJob.triggers.provider "aws-sqs-queue" -}}
{{- if not .Values.orchestrator.scaledJob.triggers.metadata.awsRegion -}}
{{- fail "orchestrator.scaledJob.triggers.metadata.awsRegion is required when using aws-sqs-queue provider. Please configure the AWS region." -}}
{{- end -}}
{{- if not .Values.orchestrator.scaledJob.triggers.metadata.queueURL -}}
{{- fail "orchestrator.scaledJob.triggers.metadata.queueURL is required when using aws-sqs-queue provider. Please configure the SQS queue URL." -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Generate scaledJob trigger metadata with defaults
Merges user-provided metadata with sensible defaults for the provider
*/}}
{{- define "orchestrator.scaledJob.trigger.metadata" -}}
{{ include "orchestrator.validateSQSTriggers" . }}
{{- $defaultMetadata := dict}}
{{- if eq .Values.orchestrator.scaledJob.triggers.provider "aws-sqs-queue" }}
{{- $defaultMetadata = dict "queueLength" "1" "scaleOnDelayed" "true" "scaleOnInFlight" "true" -}}
{{- end }}
{{- include "common.tplvalues.merge" (dict "values" (list .Values.orchestrator.scaledJob.triggers.metadata $defaultMetadata)) }}
{{- end }}

{{/* ------------------------------------------------------------------------
   Account Manager Service Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Get account-manager fullname
*/}}
{{- define "accountManager.fullname" -}}
{{ printf "%s-%s" (include "common.names.fullname" . ) "account-manager" }}
{{- end -}}

{{/*
Get account-manager image pull secrets
*/}}
{{- define "accountManager.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.accountManager.image) "global" .Values.global) }}
{{- end -}}

{{/*
Get account-manager image name
*/}}
{{- define "accountManager.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.accountManager.image "global" .Values.global) }}
{{- end -}}

{{/*
Get account-manager selector/match labels
*/}}
{{- define "accountManager.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}-account-manager
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Get account-manager standard labels (includes chart version and app version)
*/}}
{{- define "accountManager.labels.standard" -}}
{{ include "accountManager.labels.matchLabels" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}

{{/*
Get account-manager service account name
*/}}
{{- define "accountManager.serviceAccountName" -}}
{{- if .Values.accountManager.serviceAccount.create -}}
    {{ default (include "accountManager.fullname" .) .Values.accountManager.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.accountManager.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Generate account-manager environment variables
Includes database configurations
*/}}
{{- define "accountManager.envs" -}}
- name: ODIN_MYSQL_MASTER_HOST
  value: {{ include "odin.mysql.master.host" . | quote }}
- name: ODIN_MYSQL_SLAVE_HOST
  value: {{ include "odin.mysql.slave.host" . | quote }}
- name: ODIN_MYSQL_USERNAME
  value: {{ include "odin.mysql.username" . | quote }}
- name: ODIN_MYSQL_PASSWORD
  value: {{ include "odin.mysql.password" . | quote }}
{{- end }}

{{/* ------------------------------------------------------------------------
   Discovery Service Helpers
   ------------------------------------------------------------------------ */}}

{{/*
Get discovery-service fullname
*/}}
{{- define "discoveryService.fullname" -}}
{{ printf "%s-%s" (include "common.names.fullname" . ) "discovery-service" }}
{{- end -}}

{{/*
Get discovery-service image pull secrets
*/}}
{{- define "discoveryService.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.discoveryService.image) "global" .Values.global) }}
{{- end -}}

{{/*
Get discovery-service image name
*/}}
{{- define "discoveryService.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.discoveryService.image "global" .Values.global) }}
{{- end -}}

{{/*
Get discovery-service selector/match labels
*/}}
{{- define "discoveryService.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}-discovery-service
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Get discovery-service standard labels (includes chart version and app version)
*/}}
{{- define "discoveryService.labels.standard" -}}
{{ include "discoveryService.labels.matchLabels" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}

{{/*
Get discovery-service service account name
*/}}
{{- define "discoveryService.serviceAccountName" -}}
{{- if .Values.discoveryService.serviceAccount.create -}}
    {{ default (include "discoveryService.fullname" .) .Values.discoveryService.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.discoveryService.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Generate discovery-service environment variables
Includes database and Redis configurations
*/}}
{{- define "discoveryService.envs" -}}
- name: ODIN_MYSQL_MASTER_HOST
  value: {{ include "odin.mysql.master.host" . | quote }}
- name: ODIN_MYSQL_SLAVE_HOST
  value: {{ include "odin.mysql.slave.host" . | quote }}
- name: ODIN_MYSQL_USERNAME
  value: {{ include "odin.mysql.username" . | quote }}
- name: ODIN_MYSQL_PASSWORD
  value: {{ include "odin.mysql.password" . | quote }}
- name: ODIN_REDIS_HOST
  value: {{ include "odin.redis.url" . | quote }}
- name: ODIN_REDIS_PORT
  value: {{ include "odin.redis.port" . | quote }}
- name: ODIN_REDIS_PASSWORD
  value: {{ include "odin.redis.password" . | quote }}
- name: ODIN_ACCOUNT_MANAGER_HOST
  value: {{ include "accountManager.fullname" . | quote }}
- name: ODIN_ACCOUNT_MANAGER_PORT
  value: "80"
{{- end }}

{{/* ========================================================================
   UTILITY HELPERS
   Common utility functions used across templates
   ======================================================================== */}}

{{/*
Generate environment variables dynamically from config map
Usage: {{ include "odin.envs" (dict "prefix" PREFIX "config" .Values.path.to.config) }}
*/}}
{{- define "odin.envs" -}}
{{- $prefix := .prefix -}}
{{- range $key, $val := .config }}
{{- if eq (kindOf $val) "string" }}
- name: {{ printf "%s_%s" $prefix ($key | upper) }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}
