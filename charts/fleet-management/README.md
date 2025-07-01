# Fleet Management Chart

This chart provides a comprehensive, values-driven approach to GitOps fleet management using ArgoCD ApplicationSets. It replaces the static bootstrap files with dynamic, Helm-managed templates.

## What This Chart Does

### 1. Bootstrap ApplicationSets (Replaces `fleet/bootstrap/*.yaml`)
- **cluster-addons**: Manages addon deployments across the fleet
- **cluster-resources**: Manages resource deployments across the fleet  
- **cluster-monitoring**: Manages monitoring deployments across the fleet

### 2. Fleet Bootstrap ApplicationSets (Replaces `fleet/fleet-bootstrap/`)
- **fleet-registration-v2**: Handles fleet member registration
- **fleet-hub-secrets**: Manages fleet secrets and external secrets
- **fleet-members-bootstrap**: Bootstraps fleet member configurations

## Key Benefits

- **Values-Driven**: Everything configurable through `values.yaml`
- **DRY Principle**: No more repetitive YAML files
- **Centralized Logic**: All ApplicationSet generation in one place
- **Version Control**: Everything versioned with your charts
- **Easy Maintenance**: Update logic once, affects all ApplicationSets

## Architecture

```
fleet-management/
├── charts/
│   ├── fleet-common/           # Library chart with reusable templates
│   │   └── templates/
│   │       ├── _helpers.tpl    # Common helper functions
│   │       ├── _bootstrap.tpl  # Bootstrap ApplicationSet templates
│   │       ├── _matrix-generators.tpl  # Matrix generator logic
│   │       └── _fleet-bootstrap.tpl    # Fleet bootstrap templates
│   ├── application-sets/       # Your existing application-sets chart
│   └── fleet-secret/          # Your existing fleet-secret chart
├── templates/
│   ├── bootstrap-applicationsets.yaml  # Creates bootstrap ApplicationSets
│   └── fleet-bootstrap.yaml           # Creates fleet bootstrap ApplicationSets
└── values.yaml                # Configuration for all ApplicationSets
```

## Configuration

### Bootstrap ApplicationSets
```yaml
bootstrap:
  enabled: true
  groups:
    addons:
      enabled: true
      preserveResourcesOnDeletion: false
      useSelectors: false
      useVersionSelectors: true
    resources:
      enabled: true
    monitoring:
      enabled: true
```

### Fleet Bootstrap
```yaml
fleetBootstrap:
  enabled: true
  registration:
    enabled: true
  secrets:
    enabled: true
  memberBootstrap:
    enabled: true
```

### Version Management
```yaml
releases:
  addons:
    - type: "default"
      use_helm_repo_path: "true"
      chartRepo: "471112582304.dkr.ecr.eu-west-2.amazonaws.com"
      ecrChartName: "application-sets"
      version: 0.3.1
```

## Usage

### Testing
```bash
# Test template generation
helm template fleet-test . 

# Test with specific values
helm template fleet-test . -f custom-values.yaml
```

### Deployment
```bash
# Install the chart
helm install fleet-management . -n argocd

# Upgrade the chart
helm upgrade fleet-management . -n argocd
```

## Migration from Static Files

This chart replaces:
- `fleet/bootstrap/addons.yaml` → `bootstrap.groups.addons` configuration
- `fleet/bootstrap/resources.yaml` → `bootstrap.groups.resources` configuration  
- `fleet/bootstrap/monitoring.yaml` → `bootstrap.groups.monitoring` configuration
- `fleet/bootstrap/fleetv2.yaml` → `fleetBootstrap.registration` configuration
- `fleet/fleet-bootstrap/*` → `fleetBootstrap.*` configurations

## Customization

### Adding New Bootstrap Groups
```yaml
bootstrap:
  groups:
    my-new-group:
      enabled: true
      preserveResourcesOnDeletion: false
      useSelectors: false
      useVersionSelectors: true
      # ... other configuration
```

### Custom Fleet Bootstrap
```yaml
fleetBootstrap:
  customBootstrap:
    enabled: true
    name: my-custom-bootstrap
    # ... configuration
```

## Library Functions

The `fleet-common` library provides reusable templates:

- `fleet-common.bootstrapApplicationSet`: Creates bootstrap ApplicationSets
- `fleet-common.matrixGenerator`: Standard matrix generator logic
- `fleet-common.fleetRegistration`: Fleet registration ApplicationSet
- `fleet-common.fleetSecrets`: Fleet secrets management
- `fleet-common.labels`: Common Kubernetes labels
- `fleet-common.name`: Chart name expansion
- `fleet-common.fullname`: Fully qualified names

## Generated ApplicationSets

When deployed, this chart generates ApplicationSets equivalent to your original bootstrap files but with the flexibility of Helm templating and values-driven configuration.

The generated ApplicationSets maintain the same functionality as your original static files while providing much better maintainability and flexibility.
