# Djinn Application Manifests

This directory contains the deployment manifests and configuration files for the Djinn application, following DevSecOps best practices.

## Files Overview

- `djinn-manifest.yaml` - Main Kubernetes deployment manifest including namespace, deployment, service, and ingress
- `djinn-rbac-monitoring.yaml` - RBAC, monitoring, and additional Kubernetes resources
- `docker-compose.yml` - Docker Compose configuration for local development
- `Dockerfile` - Multi-stage Docker build with security hardening

## Kubernetes Deployment

### Prerequisites
- Kubernetes cluster (v1.20+)
- kubectl configured
- Ingress controller (nginx recommended)
- Cert-manager for TLS certificates

### Quick Start

1. Deploy the main application:
   ```bash
   kubectl apply -f djinn-manifest.yaml
   ```

2. Deploy RBAC and monitoring resources:
   ```bash
   kubectl apply -f djinn-rbac-monitoring.yaml
   ```

3. Verify deployment:
   ```bash
   kubectl get all -n djinn
   ```

### Configuration

The application uses ConfigMaps for configuration and Secrets for sensitive data. Update the following before deployment:

- **ConfigMap** (`djinn-config`): Environment variables and application settings
- **Secrets** (`djinn-secrets`): Database passwords and API keys (Base64 encoded)
- **Ingress**: Update the hostname from `djinn.example.com` to your domain

## Docker Compose Deployment

For local development and testing:

1. Create secrets directory:
   ```bash
   mkdir -p secrets
   echo "your-database-password" > secrets/database_password.txt
   echo "your-api-key" > secrets/api_key.txt
   ```

2. Start the application:
   ```bash
   docker-compose up -d
   ```

## Security Features

### Kubernetes Security
- Non-root user execution (UID 1001)
- ReadOnlyRootFilesystem
- Security contexts with privilege escalation disabled
- Resource limits and requests
- Network policies ready
- RBAC with least privilege access
- Pod Disruption Budget for availability

### Container Security
- Multi-stage Docker build
- Distroless/minimal base images
- Non-root user
- Security updates applied
- Health checks implemented
- Signal handling with dumb-init

## Monitoring and Observability

The manifests include:
- **Health checks**: Liveness and readiness probes
- **Resource monitoring**: CPU and memory metrics
- **Auto-scaling**: HPA based on resource utilization
- **Logging**: Structured logging ready for aggregation

## Scaling

The application is configured for horizontal scaling:
- Default: 3 replicas
- HPA: Scales from 3 to 10 replicas based on CPU (70%) and memory (80%) utilization
- PDB: Ensures minimum 2 replicas during updates

## Network Configuration

- **Service**: ClusterIP for internal communication
- **Ingress**: External access with TLS termination
- **Network isolation**: Ready for NetworkPolicy implementation

## Backup and Recovery

Consider implementing:
- Persistent volume backups for data
- Configuration backups (ConfigMaps/Secrets)
- Database backup strategies
- Disaster recovery procedures

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ENVIRONMENT` | Deployment environment | `production` |
| `LOG_LEVEL` | Logging level | `info` |
| `PORT` | Application port | `8080` |

## Troubleshooting

1. Check pod status:
   ```bash
   kubectl get pods -n djinn
   ```

2. View logs:
   ```bash
   kubectl logs -f deployment/djinn-deployment -n djinn
   ```

3. Check service connectivity:
   ```bash
   kubectl port-forward svc/djinn-service 8080:80 -n djinn
   ```

## Updates and Maintenance

For updates:
1. Update the image tag in `djinn-manifest.yaml`
2. Apply changes: `kubectl apply -f djinn-manifest.yaml`
3. Monitor rollout: `kubectl rollout status deployment/djinn-deployment -n djinn`

For rollback:
```bash
kubectl rollout undo deployment/djinn-deployment -n djinn
```

## Contributing

When modifying manifests:
1. Validate YAML syntax
2. Test in development environment first
3. Follow security best practices
4. Update documentation accordingly

## License

This configuration follows the same license as the main project.