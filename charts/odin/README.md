<!--- app-name: Odin -->

# Odin Helm Chart

Odin is a deployment tool

> For installation and uninstallation instructions, see the repository root `README.md`.

## Parameters

### Global parameters

| Name                      | Description                                        | Value |
| ------------------------- | -------------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                       | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array    | `[]`  |
| `nameOverride`            | String to partially override common.names.fullname | `""`  |
| `fullnameOverride`        | String to fully override common.names.fullname     | `""`  |
| `extraDeploy`             | Array of extra objects to deploy with the release  | `[]`  |

### Deployer parameters

| Name                                | Description                                                                          | Value             |
| ----------------------------------- | ------------------------------------------------------------------------------------ | ----------------- |
| `deployer.enabled`                  | Enable deployer deployment                                                           | `true`            |
| `deployer.image.registry`           | Deployer image registry                                                              | `docker.io`       |
| `deployer.image.repository`         | Deployer image repository                                                            | `odinhq/deployer` |
| `deployer.image.tag`                | Deployer image tag (immutable tags are recommended)                                  | `0.0.2`           |
| `deployer.image.pullPolicy`         | Image pull policy                                                                    | `IfNotPresent`    |
| `deployer.image.pullSecrets`        | Deployer image pull secrets                                                          | `[]`              |
| `deployer.security.auth.publicKey`  | ES256 public key for deployer authentication (PEM format, single-line or multiline)  | `""`              |
| `deployer.security.auth.privateKey` | ES256 private key for deployer authentication (PEM format, single-line or multiline) | `""`              |
| `deployer.labels`                   | Labels to add to all deployed objects (sub-charts are not considered)                | `{}`              |
| `deployer.annotations`              | Annotations to add to all deployed objects                                           | `{}`              |

### Deployment parameters

| Name                                          | Description                                                 | Value                |
| --------------------------------------------- | ----------------------------------------------------------- | -------------------- |
| `deployer.extraEnvVars`                       | Extra environment variables to be set on deployer container | `[]`                 |
| `deployer.migrationChangelogPath`             | Path to the migration changelog file                        | `resources/db/mysql` |
| `deployer.lifecycle`                          | Hooks for pod lifecycle                                     | `{}`                 |
| `deployer.replicaCount`                       | Number of deployer replicas                                 | `1`                  |
| `deployer.affinity`                           | Affinity for pod assignment                                 | `{}`                 |
| `deployer.nodeSelector`                       | Node labels for pod assignment                              | `{}`                 |
| `deployer.tolerations`                        | Toleration for pod                                          | `[]`                 |
| `deployer.updateStrategy.type`                | Update Strategy for deployer deployment                     | `RollingUpdate`      |
| `deployer.podAnnotations`                     | Additional pod annotations                                  | `{}`                 |
| `deployer.podLabels`                          | Additional pod labels                                       | `{}`                 |
| `deployer.resources.limits`                   | The resources limits for deployer containers                | `{}`                 |
| `deployer.resources.requests`                 | The requested resources for deployer containers             | `{}`                 |
| `deployer.livenessProbe.enabled`              | Enable livenessProbe                                        | `true`               |
| `deployer.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                     | `15`                 |
| `deployer.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                            | `5`                  |
| `deployer.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                           | `3`                  |
| `deployer.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                         | `3`                  |
| `deployer.livenessProbe.successThreshold`     | Success threshold for livenessProbe                         | `1`                  |
| `deployer.readinessProbe.enabled`             | Enable readinessProbe                                       | `true`               |
| `deployer.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                    | `15`                 |
| `deployer.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                           | `5`                  |
| `deployer.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                          | `3`                  |
| `deployer.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                        | `2`                  |
| `deployer.readinessProbe.successThreshold`    | Success threshold for readinessProbe                        | `3`                  |
| `deployer.startupProbe.enabled`               | Enable startupProbe                                         | `false`              |
| `deployer.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                      | `30`                 |
| `deployer.startupProbe.periodSeconds`         | Period seconds for startupProbe                             | `5`                  |
| `deployer.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                            | `3`                  |
| `deployer.startupProbe.failureThreshold`      | Failure threshold for startupProbe                          | `2`                  |
| `deployer.startupProbe.successThreshold`      | Success threshold for startupProbe                          | `1`                  |

### Traffic Exposure Parameters

| Name                           | Description                                               | Value       |
| ------------------------------ | --------------------------------------------------------- | ----------- |
| `deployer.service.type`        | Deployer service type                                     | `ClusterIP` |
| `deployer.service.annotations` | Provide any additional annotations which may be required. | `{}`        |

### RBAC parameters

| Name                                                   | Description                                               | Value  |
| ------------------------------------------------------ | --------------------------------------------------------- | ------ |
| `deployer.serviceAccount.create`                       | Enable the creation of a ServiceAccount for deployer pods | `true` |
| `deployer.serviceAccount.name`                         | The name of the ServiceAccount to use                     | `""`   |
| `deployer.serviceAccount.annotations`                  | Annotations for deployer service account                  | `{}`   |
| `deployer.serviceAccount.automountServiceAccountToken` | Automount API credentials for a service account           | `true` |

### Orchestrator parameters

| Name                             | Description                                                           | Value                 |
| -------------------------------- | --------------------------------------------------------------------- | --------------------- |
| `orchestrator.enabled`           | Enable orchestrator deployment                                        | `true`                |
| `orchestrator.image.registry`    | Orchestrator image registry                                           | `docker.io`           |
| `orchestrator.image.repository`  | Orchestrator image repository                                         | `odinhq/orchestrator` |
| `orchestrator.image.tag`         | Orchestrator image tag (immutable tags are recommended)               | `0.0.3`               |
| `orchestrator.image.pullPolicy`  | Image pull policy                                                     | `IfNotPresent`        |
| `orchestrator.image.pullSecrets` | Orchestrator image pull secrets                                       | `[]`                  |
| `orchestrator.labels`            | Labels to add to all deployed objects (sub-charts are not considered) | `{}`                  |
| `orchestrator.annotations`       | Annotations to add to all deployed objects                            | `{}`                  |

### Deployment parameters

| Name                              | Description                                                     | Value |
| --------------------------------- | --------------------------------------------------------------- | ----- |
| `orchestrator.extraEnvVars`       | Extra environment variables to be set on orchestrator container | `[]`  |
| `orchestrator.podAnnotations`     | Additional pod annotations                                      | `{}`  |
| `orchestrator.podLabels`          | Additional pod labels                                           | `{}`  |
| `orchestrator.resources.limits`   | The resources limits for orchestrator containers                | `{}`  |
| `orchestrator.resources.requests` | The requested resources for orchestrator containers             | `{}`  |

### RBAC parameters

| Name                                                       | Description                                                   | Value  |
| ---------------------------------------------------------- | ------------------------------------------------------------- | ------ |
| `orchestrator.serviceAccount.create`                       | Enable the creation of a ServiceAccount for orchestrator pods | `true` |
| `orchestrator.serviceAccount.name`                         | The name of the ServiceAccount to use                         | `""`   |
| `orchestrator.serviceAccount.annotations`                  | Annotations for orchestrator service account                  | `{}`   |
| `orchestrator.serviceAccount.automountServiceAccountToken` | Automount API credentials for a service account               | `true` |

### ScaledJob configuration

| Name                                                                       | Description                                                                                                                                      | Value                                                                               |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| `orchestrator.scaledJob.job.parallelism`                                   | Max number of desired pods                                                                                                                       | `100`                                                                               |
| `orchestrator.scaledJob.job.completions`                                   | Desired number of successfully finished pods                                                                                                     | `1`                                                                                 |
| `orchestrator.scaledJob.job.activeDeadlineSeconds`                         | Duration in seconds relative to the startTime that the job may be active before the system tries to terminate it; value must be positive integer | `36000`                                                                             |
| `orchestrator.scaledJob.job.backoffLimit`                                  | Number of retries before marking this job failed                                                                                                 | `2`                                                                                 |
| `orchestrator.scaledJob.pollingInterval`                                   | The time in seconds between each poll                                                                                                            | `5`                                                                                 |
| `orchestrator.scaledJob.successfulJobsHistoryLimit`                        | Number completed jobs should be kept                                                                                                             | `5`                                                                                 |
| `orchestrator.scaledJob.failedJobsHistoryLimit`                            | Number failed jobs should be kept                                                                                                                | `100`                                                                               |
| `orchestrator.scaledJob.minReplicaCount`                                   | Minimum number of replicas to scale down to                                                                                                      | `2`                                                                                 |
| `orchestrator.scaledJob.maxReplicaCount`                                   | Max number of replicas                                                                                                                           | `1000`                                                                              |
| `orchestrator.scaledJob.rollout.strategy`                                  | Rollout strategy scaledJob will use                                                                                                              | `default`                                                                           |
| `orchestrator.scaledJob.rollout.propagationPolicy`                         | Kubernetes propagation policy for cleaning up existing jobs during rollout                                                                       | `background`                                                                        |
| `orchestrator.scaledJob.scalingStrategy.strategy`                          | Scaling strategy to use                                                                                                                          | `default`                                                                           |
| `orchestrator.scaledJob.scalingStrategy.customScalingQueueLengthDeduction` | Parameter to optimize custom scaling strategy                                                                                                    | `1`                                                                                 |
| `orchestrator.scaledJob.scalingStrategy.customScalingRunningJobPercentage` | Parameter to optimize custom scaling strategy                                                                                                    | `0.5`                                                                               |
| `orchestrator.scaledJob.scalingStrategy.pendingPodConditions`              | Parameter to calculate pending job count per the specified pod conditions                                                                        | `["PodScheduled"]`                                                                  |
| `orchestrator.scaledJob.scalingStrategy.multipleScalersCalculation`        | How to calculate the target metrics when multiple scalers are defined                                                                            | `max`                                                                               |
| `orchestrator.scaledJob.triggers.provider`                                 | Type of the trigger                                                                                                                              | `aws-sqs-queue`                                                                     |
| `orchestrator.scaledJob.triggers.metadata.awsRegion`                       | AWS region                                                                                                                                       | `us-east-1`                                                                         |
| `orchestrator.scaledJob.triggers.metadata.awsEndpoint`                     | AWS endpoint                                                                                                                                     | `http://odin-elasticmq.odin.svc.cluster.local:9324`                                 |
| `orchestrator.scaledJob.triggers.metadata.queueURL`                        | AWS queue URL                                                                                                                                    | `http://odin-elasticmq.odin.svc.cluster.local:9324/000000000000/odin-request-queue` |
| `orchestrator.scaledJob.triggers.metadata.awsAccessKeyID`                  | AWS access key ID                                                                                                                                | `dummyValue`                                                                        |
| `orchestrator.scaledJob.triggers.metadata.awsSecretAccessKey`              | AWS secret access key                                                                                                                            | `dummyValue`                                                                        |
| `orchestrator.scaledJob.triggers.authentication.provider`                  | Type of the authentication                                                                                                                       | `""`                                                                                |

### runnerNamespaceCleanup configuration

| Name                                                             | Description                                   | Value                                  |
| ---------------------------------------------------------------- | --------------------------------------------- | -------------------------------------- |
| `orchestrator.runnerNamespaceCleanup.name`                       | Name for cronJob                              | `odin-orchestrator-cleanup-namespaces` |
| `orchestrator.runnerNamespaceCleanup.enabled`                    | To enable runner namespace cleanup job        | `true`                                 |
| `orchestrator.runnerNamespaceCleanup.schedule`                   | Schedule for cleaning up namespaces of runner | `0 0 * * *`                            |
| `orchestrator.runnerNamespaceCleanup.concurrencyPolicy`          | Concurrency policy for cronJob                | `Allow`                                |
| `orchestrator.runnerNamespaceCleanup.successfulJobsHistoryLimit` | Limit on storing successful job history       | `5`                                    |
| `orchestrator.runnerNamespaceCleanup.failedJobsHistoryLimit`     | Limit on storing failed job history           | `5`                                    |
| `orchestrator.runnerNamespaceCleanup.retentionPeriodDays`        | TTL for runner namespaces                     | `2`                                    |

### Discovery service parameters

| Name                                 | Description                                                           | Value              |
| ------------------------------------ | --------------------------------------------------------------------- | ------------------ |
| `discoveryService.enabled`           | Enable Discovery service deployment                                   | `true`             |
| `discoveryService.image.registry`    | Discovery service image registry                                      | `docker.io`        |
| `discoveryService.image.repository`  | Discovery service image repository                                    | `odinhq/discovery` |
| `discoveryService.image.tag`         | Discovery service image tag (immutable tags are recommended)          | `0.0.1`            |
| `discoveryService.image.pullPolicy`  | Image pull policy                                                     | `IfNotPresent`     |
| `discoveryService.image.pullSecrets` | Discovery service image pull secrets                                  | `[]`               |
| `discoveryService.labels`            | Labels to add to all deployed objects (sub-charts are not considered) | `{}`               |
| `discoveryService.annotations`       | Annotations to add to all deployed objects                            | `{}`               |

### Deployment parameters

| Name                                                  | Description                                                          | Value                |
| ----------------------------------------------------- | -------------------------------------------------------------------- | -------------------- |
| `discoveryService.extraEnvVars`                       | Extra environment variables to be set on discovery service container | `[]`                 |
| `discoveryService.migrationChangelogPath`             | Path to the migration changelog file                                 | `resources/db/mysql` |
| `discoveryService.lifecycle`                          | Hooks for pod lifecycle                                              | `{}`                 |
| `discoveryService.replicaCount`                       | Number of discovery service replicas                                 | `1`                  |
| `discoveryService.affinity`                           | Affinity for pod assignment                                          | `{}`                 |
| `discoveryService.nodeSelector`                       | Node labels for pod assignment                                       | `{}`                 |
| `discoveryService.tolerations`                        | Toleration for pod                                                   | `[]`                 |
| `discoveryService.updateStrategy.type`                | Update Strategy for Discovery service deployment                     | `RollingUpdate`      |
| `discoveryService.podAnnotations`                     | Additional pod annotations                                           | `{}`                 |
| `discoveryService.podLabels`                          | Additional pod labels                                                | `{}`                 |
| `discoveryService.resources.limits`                   | The resources limits for discovery service containers                | `{}`                 |
| `discoveryService.resources.requests`                 | The requested resources for discovery service containers             | `{}`                 |
| `discoveryService.livenessProbe.enabled`              | Enable livenessProbe                                                 | `true`               |
| `discoveryService.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                              | `15`                 |
| `discoveryService.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                     | `5`                  |
| `discoveryService.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                    | `3`                  |
| `discoveryService.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                  | `3`                  |
| `discoveryService.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                  | `1`                  |
| `discoveryService.readinessProbe.enabled`             | Enable readinessProbe                                                | `true`               |
| `discoveryService.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                             | `15`                 |
| `discoveryService.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                    | `5`                  |
| `discoveryService.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                   | `3`                  |
| `discoveryService.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                 | `2`                  |
| `discoveryService.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                 | `3`                  |
| `discoveryService.startupProbe.enabled`               | Enable startupProbe                                                  | `false`              |
| `discoveryService.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                               | `30`                 |
| `discoveryService.startupProbe.periodSeconds`         | Period seconds for startupProbe                                      | `5`                  |
| `discoveryService.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                     | `3`                  |
| `discoveryService.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                   | `2`                  |
| `discoveryService.startupProbe.successThreshold`      | Success threshold for startupProbe                                   | `1`                  |

### Traffic Exposure Parameters

| Name                                   | Description                                               | Value       |
| -------------------------------------- | --------------------------------------------------------- | ----------- |
| `discoveryService.service.type`        | Discovery service service type                            | `ClusterIP` |
| `discoveryService.service.annotations` | Provide any additional annotations which may be required. | `{}`        |

### RBAC parameters

| Name                                                           | Description                                                        | Value  |
| -------------------------------------------------------------- | ------------------------------------------------------------------ | ------ |
| `discoveryService.serviceAccount.create`                       | Enable the creation of a ServiceAccount for discovery service pods | `true` |
| `discoveryService.serviceAccount.name`                         | The name of the ServiceAccount to use                              | `""`   |
| `discoveryService.serviceAccount.annotations`                  | Annotations for discovery service account                          | `{}`   |
| `discoveryService.serviceAccount.automountServiceAccountToken` | Automount API credentials for a service account                    | `true` |

### Account manager parameters

| Name                               | Description                                                           | Value                    |
| ---------------------------------- | --------------------------------------------------------------------- | ------------------------ |
| `accountManager.enabled`           | Enable Account manager deployment                                     | `true`                   |
| `accountManager.image.registry`    | Account manager image registry                                        | `docker.io`              |
| `accountManager.image.repository`  | Account manager image repository                                      | `odinhq/account-manager` |
| `accountManager.image.tag`         | Account manager image tag (immutable tags are recommended)            | `0.0.5`                  |
| `accountManager.image.pullPolicy`  | Image pull policy                                                     | `IfNotPresent`           |
| `accountManager.image.pullSecrets` | Account manager image pull secrets                                    | `[]`                     |
| `accountManager.labels`            | Labels to add to all deployed objects (sub-charts are not considered) | `{}`                     |
| `accountManager.annotations`       | Annotations to add to all deployed objects                            | `{}`                     |

### Deployment parameters

| Name                                                | Description                                                        | Value                |
| --------------------------------------------------- | ------------------------------------------------------------------ | -------------------- |
| `accountManager.extraEnvVars`                       | Extra environment variables to be set on account manager container | `[]`                 |
| `accountManager.migrationChangelogPath`             | Path to the migration changelog file                               | `resources/db/mysql` |
| `accountManager.lifecycle`                          | Hooks for pod lifecycle                                            | `{}`                 |
| `accountManager.replicaCount`                       | Number of Account manager replicas                                 | `1`                  |
| `accountManager.affinity`                           | Affinity for pod assignment                                        | `{}`                 |
| `accountManager.nodeSelector`                       | Node labels for pod assignment                                     | `{}`                 |
| `accountManager.tolerations`                        | Toleration for pod                                                 | `[]`                 |
| `accountManager.updateStrategy.type`                | Update Strategy for Account manager deployment                     | `RollingUpdate`      |
| `accountManager.podAnnotations`                     | Additional pod annotations                                         | `{}`                 |
| `accountManager.podLabels`                          | Additional pod labels                                              | `{}`                 |
| `accountManager.resources.limits`                   | The resources limits for account manager containers                | `{}`                 |
| `accountManager.resources.requests`                 | The requested resources for account manager containers             | `{}`                 |
| `accountManager.livenessProbe.enabled`              | Enable livenessProbe                                               | `true`               |
| `accountManager.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                            | `15`                 |
| `accountManager.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                   | `5`                  |
| `accountManager.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                  | `3`                  |
| `accountManager.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                | `3`                  |
| `accountManager.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                | `1`                  |
| `accountManager.readinessProbe.enabled`             | Enable readinessProbe                                              | `true`               |
| `accountManager.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                           | `15`                 |
| `accountManager.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                  | `5`                  |
| `accountManager.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                 | `3`                  |
| `accountManager.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                               | `2`                  |
| `accountManager.readinessProbe.successThreshold`    | Success threshold for readinessProbe                               | `3`                  |
| `accountManager.startupProbe.enabled`               | Enable startupProbe                                                | `false`              |
| `accountManager.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                             | `30`                 |
| `accountManager.startupProbe.periodSeconds`         | Period seconds for startupProbe                                    | `5`                  |
| `accountManager.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                   | `3`                  |
| `accountManager.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                 | `2`                  |
| `accountManager.startupProbe.successThreshold`      | Success threshold for startupProbe                                 | `1`                  |

### Traffic Exposure Parameters

| Name                                 | Description                                               | Value       |
| ------------------------------------ | --------------------------------------------------------- | ----------- |
| `accountManager.service.type`        | Account manager service type                              | `ClusterIP` |
| `accountManager.service.annotations` | Provide any additional annotations which may be required. | `{}`        |

### RBAC parameters

| Name                                                         | Description                                                      | Value  |
| ------------------------------------------------------------ | ---------------------------------------------------------------- | ------ |
| `accountManager.serviceAccount.create`                       | Enable the creation of a ServiceAccount for account manager pods | `true` |
| `accountManager.serviceAccount.name`                         | The name of the ServiceAccount to use                            | `""`   |
| `accountManager.serviceAccount.annotations`                  | Annotations for account manager service account                  | `{}`   |
| `accountManager.serviceAccount.automountServiceAccountToken` | Automount API credentials for a service account                  | `true` |

### Minio parameters

| Name                              | Description                            | Value                          |
| --------------------------------- | -------------------------------------- | ------------------------------ |
| `minio.fullnameOverride`          | Fullname override for minio deployment | `odin-minio`                   |
| `minio.enabled`                   | Enable minio deployment                | `true`                         |
| `minio.image.repository`          | Minio image repository                 | `quay.io/minio/minio`          |
| `minio.image.tag`                 | Minio image tag                        | `RELEASE.2024-12-18T13-15-44Z` |
| `minio.image.pullPolicy`          | Minio image pull policy                | `IfNotPresent`                 |
| `minio.rootUser`                  | Minio root user                        | `admin`                        |
| `minio.rootPassword`              | Minio root password                    | `admin@123`                    |
| `minio.region`                    | Minio region                           | `us-east-1`                    |
| `minio.replicas`                  | Minio replicas                         | `3`                            |
| `minio.storageClass`              | Storage class to use                   | `""`                           |
| `minio.resources.requests.memory` | Minio resources requests memory        | `1Gi`                          |
| `minio.persistence.enabled`       | Enable persistence                     | `true`                         |
| `minio.persistence.storageClass`  | Storage class to use                   | `""`                           |
| `minio.persistence.size`          | Size of the persistent volume          | `10Gi`                         |
| `minio.buckets[0].name`           | Odin backup bucket name                | `odin-backup-bucket`           |
| `minio.buckets[0].policy`         | Odin backup bucket policy              | `public`                       |
| `minio.buckets[1].name`           | Odin state bucket name                 | `odin-state-bucket`            |
| `minio.buckets[1].policy`         | Odin state bucket policy               | `public`                       |

### Database parameters

| Name                                                 | Description                            | Value                                                       |
| ---------------------------------------------------- | -------------------------------------- | ----------------------------------------------------------- |
| `mysql.external.enabled`                             | Enable external Mysql                  | `false`                                                     |
| `mysql.external.username`                            | External Mysql username                | `root`                                                      |
| `mysql.external.password`                            | External Mysql password                | `""`                                                        |
| `mysql.external.master.host`                         | External Mysql master host             | `mysql-master`                                              |
| `mysql.external.slave.host`                          | External Mysql slave host              | `mysql-slave`                                               |
| `mysql.fullnameOverride`                             | Name override for the mysql deployment | `odin-mysql`                                                |
| `mysql.finalizers`                                   | Finalizers for the mysql deployment    | `["percona.com/delete-ssl","percona.com/delete-mysql-pvc"]` |
| `mysql.secretsName`                                  | Secrets name for the mysql deployment  | `internal-odin-mysql`                                       |
| `mysql.mysql.clusterType`                            | Cluster type                           | `async`                                                     |
| `mysql.mysql.expose.enabled`                         | Enable MySQL service exposure          | `false`                                                     |
| `mysql.orchestrator.enabled`                         | Enable orchestrator deployment         | `true`                                                      |
| `mysql.proxy.haproxy.enabled`                        | Enable HAProxy                         | `true`                                                      |
| `mysql.proxy.haproxy.resources.requests.memory`      | HAProxy resources requests memory      | `256Mi`                                                     |
| `mysql.proxy.haproxy.resources.limits.memory`        | HAProxy resources limits memory        | `512Mi`                                                     |
| `mysql.backup.enabled`                               | Enable backup deployment               | `true`                                                      |
| `mysql.backup.schedule`                              | Automatic Backup schedule              | `nil`                                                       |
| `mysql.backup.storages.s3local.s3.endpointUrl`       | S3 local storage endpoint URL          | `http://odin-minio:9000`                                    |
| `mysql.backup.storages.s3local.s3.bucket`            | S3 local storage bucket                | `odin-backup-bucket`                                        |
| `mysql.backup.storages.s3local.s3.credentialsSecret` | S3 local storage credentials secret    | `odin-minio-s3-credentials`                                 |
| `mysql.backup.storages.s3local.s3.region`            | S3 local storage region                | `us-east-1`                                                 |
| `mysql.backup.storages.s3local.type`                 | S3 local storage type                  | `s3`                                                        |
| `mysql.backup.storages.s3local.verifyTLS`            | S3 local storage verify TLS            | `false`                                                     |

### Redis parameters

| Name                                | Description                                      | Value                 |
| ----------------------------------- | ------------------------------------------------ | --------------------- |
| `redis.external.enabled`            | Enable external Redis                            | `false`               |
| `redis.external.host`               | External Redis host                              | `redis-master`        |
| `redis.external.port`               | External Redis port                              | `6379`                |
| `redis.external.password`           | External Redis password (leave empty if no auth) | `""`                  |
| `redis.external.database`           | External Redis database number                   | `0`                   |
| `redis.fullnameOverride`            | Fullname override for redis deployment           | `odin-redis`          |
| `redis.image.registry`              | Redis image registry                             | `docker.io`           |
| `redis.image.repository`            | Redis image repository                           | `bitnamilegacy/redis` |
| `redis.image.tag`                   | Redis image tag                                  | `8.2.1-debian-12-r0`  |
| `redis.architecture`                | Redis architecture                               | `standalone`          |
| `redis.auth.enabled`                | Enable Redis authentication                      | `false`               |
| `redis.master.count`                | Number of Redis master instances                 | `1`                   |
| `redis.master.service.type`         | Redis master service type                        | `ClusterIP`           |
| `redis.master.persistence.enabled`  | Enable Redis master persistence                  | `false`               |
| `redis.master.containerPorts.redis` | Redis master container port                      | `6379`                |
| `redis.replica.replicaCount`        | Number of Redis replicas                         | `0`                   |
| `redis.sentinel.enabled`            | Enable Redis sentinel                            | `false`               |

### Elasticsearch parameters

| Name                                         | Description                                                                                                                                                                                                                                                             | Value                         |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| `elasticsearch.external.enabled`             | Enable external elasticsearch                                                                                                                                                                                                                                           | `false`                       |
| `elasticsearch.external.host`                | External Elasticsearch host                                                                                                                                                                                                                                             | `elasticsearch-host`          |
| `elasticsearch.external.port`                | Elasticsearch Redis port                                                                                                                                                                                                                                                | `9200`                        |
| `elasticsearch.external.username`            | External Elasticsearch username (leave empty if no auth)                                                                                                                                                                                                                | `""`                          |
| `elasticsearch.external.password`            | External Elasticsearch password (leave empty if no auth)                                                                                                                                                                                                                | `""`                          |
| `elasticsearch.fullnameOverride`             | Fullname override for redis deployment                                                                                                                                                                                                                                  | `odin-elasticsearch`          |
| `elasticsearch.clusterName`                  | Elasticsearch cluster name                                                                                                                                                                                                                                              | `odin-elasticsearch`          |
| `elasticsearch.image.registry`               | Elasticsearch image registry                                                                                                                                                                                                                                            | `docker.io`                   |
| `elasticsearch.image.repository`             | Elasticsearch image repository                                                                                                                                                                                                                                          | `bitnamilegacy/elasticsearch` |
| `elasticsearch.image.tag`                    | Elasticsearch image tag                                                                                                                                                                                                                                                 | `9.1.2-debian-12-r0`          |
| `elasticsearch.sysctlImage.enabled`          | Enable kernel settings modifier image                                                                                                                                                                                                                                   | `false`                       |
| `elasticsearch.security.enabled`             | Enable X-Pack Security settings                                                                                                                                                                                                                                         | `false`                       |
| `elasticsearch.security.elasticPassword`     | Custom Elasticsearch authentication Password                                                                                                                                                                                                                            | `changeme`                    |
| `elasticsearch.security.tls.autoGenerated`   | Create self-signed TLS certificates.                                                                                                                                                                                                                                    | `true`                        |
| `elasticsearch.master.replicaCount`          | Number of master-eligible replicas to deploy                                                                                                                                                                                                                            | `3`                           |
| `elasticsearch.master.resourcesPreset`       | Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if elasticsearch.master.resources is set (elasticsearch.master.resources is recommended for production).             | `small`                       |
| `elasticsearch.master.resources`             | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                                                                       | `{}`                          |
| `elasticsearch.master.heapSize`              | Elasticsearch master node heap size.                                                                                                                                                                                                                                    | `128m`                        |
| `elasticsearch.master.persistence.size`      | Persistent Volume Size                                                                                                                                                                                                                                                  | `16Gi`                        |
| `elasticsearch.data.replicaCount`            | Number of data-only replicas to deploy                                                                                                                                                                                                                                  | `2`                           |
| `elasticsearch.data.resourcesPreset`         | Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if elasticsearch.data.resources is set (elasticsearch.data.resources is recommended for production).                 | `medium`                      |
| `elasticsearch.data.resources`               | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                                                                       | `{}`                          |
| `elasticsearch.data.heapSize`                | Elasticsearch data node heap size.                                                                                                                                                                                                                                      | `1024m`                       |
| `elasticsearch.data.persistence.size`        | Persistent Volume Size                                                                                                                                                                                                                                                  | `15Gi`                        |
| `elasticsearch.coordinating.replicaCount`    | Number of coordinating-only replicas to deploy                                                                                                                                                                                                                          | `0`                           |
| `elasticsearch.coordinating.resourcesPreset` | Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if elasticsearch.coordinating.resources is set (elasticsearch.coordinating.resources is recommended for production). | `small`                       |
| `elasticsearch.coordinating.resources`       | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                                                                       | `{}`                          |
| `elasticsearch.coordinating.heapSize`        | Elasticsearch coordinating node heap size.                                                                                                                                                                                                                              | `128m`                        |
| `elasticsearch.ingest.enabled`               | Enable ingest nodes                                                                                                                                                                                                                                                     | `true`                        |
| `elasticsearch.ingest.replicaCount`          | Number of ingest-only replicas to deploy                                                                                                                                                                                                                                | `1`                           |
| `elasticsearch.ingest.resourcesPreset`       | Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if elasticsearch.ingest.resources is set (elasticsearch.ingest.resources is recommended for production).             | `small`                       |
| `elasticsearch.ingest.resources`             | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                                                                       | `{}`                          |
| `elasticsearch.ingest.heapSize`              | Elasticsearch ingest node heap size.                                                                                                                                                                                                                                    | `128m`                        |

### Fluentbit parameters

| Name                                  | Description                                                                   | Value                      |
| ------------------------------------- | ----------------------------------------------------------------------------- | -------------------------- |
| `fluentbit.external.enabled`          | Enable external Fluent Bit                                                    | `false`                    |
| `fluentbit.fullnameOverride`          | Fullname override for Fluent Bit deployment                                   | `odin-fluentbit`           |
| `fluentbit.image.registry`            | Fluent Bit image registry                                                     | `docker.io`                |
| `fluentbit.image.repository`          | Fluent Bit image repository                                                   | `bitnamilegacy/fluent-bit` |
| `fluentbit.image.tag`                 | Fluent Bit image tag                                                          | `4.0.7`                    |
| `fluentbit.daemonset.enabled`         | Use a daemonset instead of a deployment. `replicaCount` will not take effect. | `true`                     |
| `fluentbit.existingConfigMap`         | Name of an existing ConfigMap with the Fluent Bit config file                 | `odin-fluentbit-config`    |
| `fluentbit.resources.limits.cpu`      | CPU limit for Fluent Bit                                                      | `500m`                     |
| `fluentbit.resources.limits.memory`   | Memory limit for Fluent Bit                                                   | `512M`                     |
| `fluentbit.resources.requests.cpu`    | CPU request for Fluent Bit                                                    | `500m`                     |
| `fluentbit.resources.requests.memory` | Memory request for Fluent Bit                                                 | `100M`                     |
| `fluentbit.rbac.create`               | Create RBAC resources for Fluent Bit                                          | `true`                     |
| `fluentbit.rbac.nodeAccess`           | Enable node-level access for Fluent Bit                                       | `true`                     |
| `fluentbit.rbac.rules[0].apiGroups`   | API groups for Fluent Bit RBAC rules                                          | `[""]`                     |
| `fluentbit.rbac.rules[0].resources`   | Resources for Fluent Bit RBAC rules                                           | `["pods","namespaces"]`    |
| `fluentbit.rbac.rules[0].verbs`       | Verbs for Fluent Bit RBAC rules                                               | `["get","list","watch"]`   |

### ElasticMQ parameters

| Name                                                        | Description                                                                                                                                                    | Value                                                                                                                                                                                                                                                                                  |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `elasticMQ.external.enabled`                                | Enable external SQS                                                                                                                                            | `false`                                                                                                                                                                                                                                                                                |
| `elasticMQ.external.requestQueueUrl`                        | External SQS Request Queue URL                                                                                                                                 | `us-east-1.requestQueue.aws.com`                                                                                                                                                                                                                                                       |
| `elasticMQ.external.responseQueueUrl`                       | External SQS Response Queue URL                                                                                                                                | `us-east-1.responseQueue.aws.com`                                                                                                                                                                                                                                                      |
| `elasticMQ.fullnameOverride`                                | Fullname override for ElasticMQ deployment                                                                                                                     | `odin-elasticmq`                                                                                                                                                                                                                                                                       |
| `elasticMQ.image.repository`                                | ElasticMQ image repository                                                                                                                                     | `softwaremill/elasticmq`                                                                                                                                                                                                                                                               |
| `elasticMQ.image.tag`                                       | ElasticMQ image tag                                                                                                                                            | `1.6.15`                                                                                                                                                                                                                                                                               |
| `elasticMQ.image.pullPolicy`                                | ElasticMQ image pull policy                                                                                                                                    | `IfNotPresent`                                                                                                                                                                                                                                                                         |
| `elasticMQ.replicaCount`                                    | Number of ElasticMQ replicas to run                                                                                                                            | `1`                                                                                                                                                                                                                                                                                    |
| `elasticMQ.startServices`                                   | Comma-separated list of AWS CLI service names which are the only ones allowed to be used (other services will then by default be prevented from being loaded). | `sqs`                                                                                                                                                                                                                                                                                  |
| `elasticMQ.aws.region`                                      | Region for AWS Service.                                                                                                                                        | `us-east-1`                                                                                                                                                                                                                                                                            |
| `elasticMQ.aws.accessKeyId`                                 | AWS Access Key ID                                                                                                                                              | `dummyValue`                                                                                                                                                                                                                                                                           |
| `elasticMQ.aws.secretAccessKey`                             | AWS Secret Access Key                                                                                                                                          | `dummyValue`                                                                                                                                                                                                                                                                           |
| `elasticMQ.mqConfig`                                        | Configuration for message queue                                                                                                                                | `queues-storage {
  enabled = true
  path = "/data/queues.conf"
}
messages-storage {
  enabled = true
  uri = "jdbc:h2:/data/elasticmq"
}
rest-sqs {
  bind-port = 9324
  bind-hostname = "0.0.0.0"
}
rest-stats {
  enabled = true
  bind-port = 9325
  bind-hostname = "0.0.0.0"
}
` |
| `elasticMQ.persistence.storageClass`                        | Persistent Volume storage class                                                                                                                                | `""`                                                                                                                                                                                                                                                                                   |
| `elasticMQ.persistence.size`                                | Persistent Volume size                                                                                                                                         | `2Gi`                                                                                                                                                                                                                                                                                  |
| `elasticMQ.resources.requests.memory`                       | Memory request for ElasticMQ                                                                                                                                   | `512Mi`                                                                                                                                                                                                                                                                                |
| `elasticMQ.resources.requests.cpu`                          | CPU request for ElasticMQ                                                                                                                                      | `250m`                                                                                                                                                                                                                                                                                 |
| `elasticMQ.resources.limits.memory`                         | Memory limit for ElasticMQ                                                                                                                                     | `1Gi`                                                                                                                                                                                                                                                                                  |
| `elasticMQ.resources.limits.cpu`                            | CPU limit for ElasticMQ                                                                                                                                        | `500m`                                                                                                                                                                                                                                                                                 |
| `elasticMQ.service.type`                                    | ElasticMQ service type                                                                                                                                         | `ClusterIP`                                                                                                                                                                                                                                                                            |
| `elasticMQ.service.port`                                    | ElasticMQ service port                                                                                                                                         | `4566`                                                                                                                                                                                                                                                                                 |
| `elasticMQ.service.nodePort`                                | ElasticMQ service nodePort                                                                                                                                     | `""`                                                                                                                                                                                                                                                                                   |
| `elasticMQ.extraEnvVars[0].name`                            | Extra environment variable name                                                                                                                                | `SQS_ENDPOINT_STRATEGY`                                                                                                                                                                                                                                                                |
| `elasticMQ.extraEnvVars[0].value`                           | Extra environment variable value                                                                                                                               | `path`                                                                                                                                                                                                                                                                                 |
| `elasticMQ.createQueues.enabled`                            | When enabled, will trigger the creation of queue names passed in elasticMQ.createQueues.queues.                                                                | `true`                                                                                                                                                                                                                                                                                 |
| `elasticMQ.createQueues.queues[0].name`                     | Queue name                                                                                                                                                     | `odin-request-queue`                                                                                                                                                                                                                                                                   |
| `elasticMQ.createQueues.queues[0].defaultVisibilityTimeout` | Queue default visibility timeout                                                                                                                               | `30 seconds`                                                                                                                                                                                                                                                                           |
| `elasticMQ.createQueues.queues[1].name`                     | Queue name                                                                                                                                                     | `odin-response-queue`                                                                                                                                                                                                                                                                  |
| `elasticMQ.createQueues.queues[1].defaultVisibilityTimeout` | Queue default visibility timeout                                                                                                                               | `30 seconds`                                                                                                                                                                                                                                                                           |
