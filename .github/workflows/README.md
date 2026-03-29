# GitHub Actions CI/CD Workflows

This directory contains GitHub Actions workflows for automated infrastructure deployment using Terraform.

## Workflows

### 1. Validate (`validate.yml`)

Validates Terraform configuration on every pull request and commit.

**Triggers**:
- Pull requests with changes to `infrastructure/`
- Commits to `main` branch
- Manual trigger

**Jobs**:
- Terraform format validation
- Terraform validate for all providers
- TFLint linting
- Checkov security scanning

### 2. Plan (`plan.yml`)

Creates Terraform plans on pull requests for review before deployment.

**Triggers**:
- Pull requests with changes to `infrastructure/`
- Manual workflow dispatch

**Jobs**:
- AWS plan job
- Azure plan job
- GCP plan job
- PR comments with plan output

### 3. Apply (`apply.yml`)

Applies Terraform configuration to deploy infrastructure.

**Triggers**:
- Push to `main` branch
- Manual workflow dispatch with environment selection

**Jobs**:
- AWS apply
- Azure apply
- GCP apply
- Requires manual approval for production

## Setup Instructions

### GitHub Repository Secrets

Add these secrets to your repository:

**AWS**:
- `AWS_ACCOUNT_ID`: Your AWS account ID
- `AWS_REGION`: Default AWS region (e.g., us-east-1)

**Azure**:
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID
- `AZURE_TENANT_ID`: Azure tenant ID
- `AZURE_CLIENT_ID`: Service principal client ID

**GCP**:
- `GCP_PROJECT_ID`: GCP project ID
- `WIF_PROVIDER`: Workload identity federation provider
- `WIF_SERVICE_ACCOUNT`: Service account for authentication

### Environment Variables

Configure these in workflow files:

```yaml
env:
  TF_VERSION: '1.6.0'
  AWS_REGION: 'us-east-1'
  AZURE_REGION: 'eastus'
  GCP_REGION: 'us-central1'
```

## Workflow Status Badges

Add to README.md:

```markdown
![Validate](https://github.com/your-org/terraspan/workflows/Terraform%20Validate/badge.svg)
![Plan](https://github.com/your-org/terraspan/workflows/Terraform%20Plan/badge.svg)
![Apply](https://github.com/your-org/terraspan/workflows/Terraform%20Apply/badge.svg)
```

## Best Practices

✅ **Validate before planning** - Catch errors early
✅ **Review plans carefully** - Don't apply without understanding changes
✅ **Require approvals** for production deployments
✅ **Log all operations** for audit trails
✅ **Test in dev/staging** before production
✅ **Use OIDC authentication** instead of secrets
✅ **Implement role-based access** for workflows
✅ **Timeout long-running jobs** to prevent hanging

## Customization

### Adding a New Cloud Provider

1. Create environment directory: `infrastructure/{provider}/environments/{env}`
2. Create workflow job in `plan.yml` and `apply.yml`
3. Add cloud-specific authentication
4. Configure backend for state storage

### Environment-Specific Workflows

Create separate workflow for each environment:

- `deploy-dev.yml` - Auto-deploy to dev
- `deploy-staging.yml` - Manual approval for staging
- `deploy-prod.yml` - Requires multiple approvals

### Integration with External Tools

- **Slack notifications**: Add `slack-notify` action
- **Database migrations**: Add migration steps before apply
- **Testing**: Add infrastructure validation tests
- **Cost estimation**: Add cost estimation tools

## Troubleshooting

### Workflow Timeout

Increase timeout in workflow:
```yaml
jobs:
  apply:
    runs-on: ubuntu-latest
    timeout-minutes: 60
```

### Authentication Failures

Verify credentials in GitHub repository settings:
1. Settings → Secrets and variables → Actions
2. Check all required secrets are present
3. Verify secret values are current

### State Lock Issues

If state is locked from previous run:
```bash
# Manually unlock (use with caution)
aws dynamodb delete-item --table-name terraspan-locks \
  --key '{"LockID":{"S":"aws/dev/terraform.tfstate"}}'
```

## Related Documentation

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [TerraSpan CI/CD Guide](../../docs/cicd.md)
- [Deployment Guide](../../docs/deployment.md)
