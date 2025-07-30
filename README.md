# Deploy Kubernetes applications using Kubeo Helm Charts

Kubeo Helm Charts helps you to deploy application effortless in Kubernetes.

## Introduction

Run single http application:

```bash
helm upgrade -i kubeo-app oci://ghcr.io/kubeo-io/app \
    --set image.repository=nginx \
    --set ingress.enabled=true \
    --set default.containerPort=80 \
    --set default.host=test.app.mycluster.local
```

Kubeo creates `Deployment`, `Service` and `Ingress` for you.

## Deploy using a GitOps strategy

⚠️ This feature is experimental and may fails for your use case.

See the `sample/gitops` folder for an [example configuration.](./sample/gitops)

Add to your CI/CD pipeline the following command. The command will scan your git history and apply changes in case you make changes either in `values.yml` file or `release.yml` file.

```bash
bin/kubeo-gitops sample
```

## Default configuration options for the App Chart

| Section | Description | Enabled by Default | Example |
|---------|-------------|-------------------|---------|
| `replicaCount` | Number of pod replicas (overridden if HPA is enabled) | `1` | `replicaCount: 3` |
| `nameOverride` | Override the chart name | `""` (disabled) | `nameOverride: "my-app"` |
| `fullnameOverride` | Override the full resource name | `""` (disabled) | `fullnameOverride: "my-full-app-name"` |
| `imagePullSecrets` | Secrets for pulling images from private registries | `[]` (disabled) | `imagePullSecrets: [name: "myregistry"]` |
| `labels` | Custom deployment selector labels | `{}` (disabled) | `labels: {app: "myapp", version: "v1"}` |
| `nodeSelector` | Node selection constraints | `{}` (disabled) | `nodeSelector: {disktype: "ssd"}` |
| `affinity` | Pod affinity rules | `{}` (disabled) | `affinity: {nodeAffinity: {...}}` |
| `image` | Container image configuration | Required | `image: {repository: "nginx", tag: "latest", pullPolicy: "Always"}` |
| `default.host` | Default hostname for ingress/route | Required | `default.host: "myapp.example.com"` |
| `default.serviceAccountName` | Service account name | `"default"` | `default.serviceAccountName: "custom-sa"` |
| `default.enabledContainers` | Which containers to enable | `"*"` (all) | `default.enabledContainers: "app,sidecar"` |
| `default.containerPort` | Default container port | `8080` | `default.containerPort: 3000` |
| `default.servicePort` | Default service port | `80` | `default.servicePort: 8080` |
| `default.ingressClassName` | Ingress class name | `"nginx"` | `default.ingressClassName: "traefik"` |
| `vault` | HashiCorp Vault integration | `enabled: false` | `vault: {enabled: true, type: "hashicorp", role: "app-role"}` |
| `config` | ConfigMap configuration files | `{}` (disabled) | `config: [{name: "app-config", mountPath: "/app/config.yaml", data: "key: value"}]` |
| `serviceAccount` | Service account management | `create: false` | `serviceAccount: {create: true, name: "my-sa"}` |
| `containers` | Container definitions | Default app container | `containers: [{name: "app", image: {}, env: [], ports: {}}]` |
| `jobs` | Kubernetes Jobs configuration | `[]` (disabled) | `jobs: [{name: "migration", command: ["migrate"], restartPolicy: "Never"}]` |
| `resources` | CPU/Memory limits and requests | `{}` (disabled) | `resources: {limits: {cpu: "2", memory: "2Gi"}, requests: {cpu: "100m", memory: "1Gi"}}` |
| `pdb` | Pod Disruption Budget | `enabled: false` | `pdb: {enabled: true, minAvailable: 2}` |
| `probes` | Health check probes (unified config) | `enabled: false` | `probes: {enabled: true, httpGet: "/health", port: 8080}` |
| `livenessProbe` | Liveness probe (individual config) | `{}` (disabled) | `livenessProbe: {httpGet: {path: "/health", port: 8080}}` |
| `readinessProbe` | Readiness probe (individual config) | `{}` (disabled) | `readinessProbe: {httpGet: {path: "/ready", port: 8080}}` |
| `startupProbe` | Startup probe (individual config) | `{}` (disabled) | `startupProbe: {httpGet: {path: "/startup", port: 8080}}` |
| `podSecurityContext` | Pod-level security context | `{}` (disabled) | `podSecurityContext: {runAsUser: 1000, runAsGroup: 1000}` |
| `securityContext` | Container-level security context | `{}` (disabled) | `securityContext: {allowPrivilegeEscalation: false, readOnlyRootFilesystem: true}` |
| `annotations` | Pod annotations | `{}` (disabled) | `annotations: {"prometheus.io/scrape": "true"}` |
| `tolerations` | Pod tolerations | `[]` (disabled) | `tolerations: [{key: "node-type", operator: "Equal", value: "gpu"}]` |
| `updateStrategy` | Deployment update strategy | RollingUpdate (25% surge/unavailable) | `updateStrategy: {type: "Recreate"}` |
| `service` | Kubernetes Service configuration | `enabled: true, type: ClusterIP` | `service: {enabled: true, type: "NodePort", port: 8080}` |
| `route` | OpenShift Route configuration | `{}` (disabled) | `route: {enabled: true, host: "app.openshift.local", tls: {...}}` |
| `ingress` | Kubernetes Ingress configuration | `{}` (disabled) | `ingress: {enabled: true, hosts: [{host: "app.example.com"}]}` |
| `env` | Global environment variables | `[]` (disabled) | `env: [{name: "NODE_ENV", value: "production"}]` |
| `persistence.volumes` | Pod volumes | `[]` (disabled) | `persistence.volumes: [{name: "data", emptyDir: {}}]` |
| `persistence.mounts` | Volume mounts | `[]` (disabled) | `persistence.mounts: [{name: "data", mountPath: "/data"}]` |
| `persistence.storage` | Persistent storage | `[]` (disabled) | `persistence.storage: [{name: "data", type: "oc-nfs", capacity: "10Gi"}]` |
| `vpa` | Vertical Pod Autoscaler | `enabled: false` | `vpa: {enabled: true, updateMode: "Auto"}` |
| `hpa` | Horizontal Pod Autoscaler | `enabled: false` | `hpa: {enabled: true, minReplicas: 2, maxReplicas: 10, metrics: [...]}` |
| `serviceMonitor` | Prometheus ServiceMonitor | `enabled: false` | `serviceMonitor: {enabled: true, endpoints: [{path: "/metrics", port: 9090}]}` |
| `serviceEndpoints` | External service endpoints | `{}` (disabled) | `serviceEndpoints: [{addresses: [{ip: "192.168.1.1"}], ports: [{port: 9100}]}]` |
| `secretManager` | External secret management | `enabled: false` | `secretManager: {enabled: true, type: "external-secrets.io", provider: "awsSecretsManager"}` |

## Configuration sample



## Helm Tips

### Install Helm

[Check the latest instructions to install Helm](https://helm.sh/docs/intro/install/)

### Adding your application version before deploying

ℹ The `--app-version` refers to the container image version in the container registry and  `--version` refers to the helm Chart version itself.

```bash
helm pull oci://ghcr.io/kubeo-io/app --version 1.1.1 --untar --untardir .helm
helm package .helm/app  --app-version 1.2.3
helm install release-name ./app-1.1.1.tgz ... [ give helm options ]
```

Now `helm ls` will be consistent with your app version.

```text
$ helm ls
NAME       	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART    	APP VERSION
nginx-teste	default  	3       	2025-07-02 17:07:16.680189 -0300 -03	deployed	app-1.1.1	1.2.3 
```

## Daily examples

### Shell with storage

```bash
cat <<EOF > values.yml
image:
  repository: ubuntu
  tag: latest
persistence:
  mounts:
    - name: data
      mountPath: /data
  storage:
    - name: data
      type: pvc
      capacity: 200Gi
      accessMode: ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
EOF
helm upgrade -i shell oci://ghcr.io/kubeo-io/app -f values.yml
````

## License

Kubeo Helm Charts is released under Apache License.
