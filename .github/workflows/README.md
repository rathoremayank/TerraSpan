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

### 4. Deploy to GitHub Pages (`deploy-pages.yml`)

Automatically deploys the TerraSpan static website to GitHub Pages.

**Triggers**:
- Push to `main` branch with changes to `website/`
- Manual workflow dispatch

**Jobs**:
- **Build**: Validates website files (HTML, CSS, JS)
- **Deploy**: Deploys validated site to GitHub Pages
- **Notify**: Sends deployment notifications
- **Security Scan**: Validates security in website content

**Features**:
- Zero-dependency pure HTML/CSS/JS validation
- No build process required
- Automatic GitHub Pages artifact upload
- Environment configuration for Pages
- Security validation for HTML files
- HTML syntax validation

**Validation Process**:
```bash
cd website/static
# Validates all HTML files exist
# Checks CSS and JavaScript are present
# Validates HTML syntax
# Checks for security issues
# Uploads to GitHub Pages
```

### 5. Complete Pipeline (`pipeline.yml`)

Comprehensive CI/CD pipeline combining all stages.

**Triggers**:
- Pull requests (validation & planning)
- Push to `main` branch (full deployment)
- Manual workflow dispatch

**Stages**:

#### Validation Stage
- Infrastructure validation (multiple Terraform versions)
- Linting with TFLint
- Security scanning with Checkov
- Website file validation (HTML, CSS, JS presence and syntax)

#### Planning Stage
- AWS infrastructure plan
- Azure infrastructure plan
- GCP infrastructure plan
- All trigger on pull requests for review

#### Approval Gate
- Manual approval environment for production
- Prevents accidental deployments

#### Deployment Stage
- Infrastructure deployment to all clouds
- Website deployment to GitHub Pages
- Parallel execution

#### Notification Stage
- Pipeline success notifications
- Deployment completion notifications
- Job summaries in GitHub

#### Summary Stage
- Automated job summary with links
- Complete audit trail

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

### GitHub Pages Configuration

To enable GitHub Pages deployment:

1. Go to repository **Settings** → **Pages**
2. Set **Source** to "GitHub Actions"
3. (Optional) Configure custom domain
4. Workflows will automatically deploy to `gh-pages` branch

No additional secrets needed for GitHub Pages (uses OIDC token).

### Environment Variables

Configure these in workflow files:

```yaml
env:
  TF_VERSION: '1.6.0'
  AWS_REGION: 'us-east-1'
  AZURE_REGION: 'eastus'
![Deploy Pages](https://github.com/your-org/terraspan/workflows/Deploy%20to%20GitHub%20Pages/badge.svg)
![Pipeline](https://github.com/your-org/terraspan/workflows/Complete%20CI%2FCD%20Pipeline/badge.svg)
```

## Workflow Execution Visualization

```
Pull Request
    └─> Validate
    └─> Lint
    └─> Security Scan
    └─> Plan (AWS/Azure/GCP)
        └─> Comment with Plan Results

Merge to Main
    └─> Validate
    └─> Lint
    └─> Security Scan
    └─> (Manual Approval)
        ├─> Deploy Infrastructure
        └─> Deploy Website to GitHub Pages
            └─> Notify Success
  GCP_REGION: 'us-central1'
```
Workflow Customization

### Adding a New Cloud Provider

1. Create environment directory: `infrastructure/{provider}/environments/{env}`
2. Create workflow job in `plan.yml` and `apply.yml`
3. Add cloud-specific authentication
4. Configure backend for state storage

### Customizing Website Deployment

**Update website content**:
1. Edit HTML files in `website/static/`
2. Update `website/static/css/style.css` for styling
3. Update `website/static/js/main.js` for interactivity
4. Push changes to `main` branch
5. Workflow automatically deploys

**Add custom domain**:
1. Create `website/static/CNAME` file
2. Add domain: `your-domain.com`
3. GitHub Pages will automatically use it

**Workflow configuration** (in `deploy-pages.yml`):
```yaml
- name: Upload artifact
  uses: actions/upload-pages-artifact@v2
  with:
    path: 'website/static'  # Points to static website
```

### Environment-Specific Workflows

Create separate workflow for each environment:

- `deploy-dev.yml` - Auto-deploy to dev
- `deploy-staging.yml` - Manual approval for staging
- `deploy-prod.yml` - Requires multiple approvals

### Integration with External Tools

- **Slack notifications**: Add `slack-notify` action after deployment
- **Database migrations**: Add migration steps before apply
- **Testing**: Add infrastructure validation tests
- **Cost estimation**: Add cost estimation tools (TFCost, InfraCost)
- **Performance monitoring**: Add performance tests
- **Analytics**: Track deployment metric

### Adding a New Cloud Provider

1. Create environment directory: `infrastructure/{provider}/environments/{env}`
2. Create workflow job in `plan.yml` and `apply.yml`
3. Add cloud-specific authentication
4. Configure backend for state storage

### Environment-Specific Workflows

Create separate workflow for each environment:
Website Deployment Issues

**404 on GitHub Pages**:
1. Check "Settings" → "Pages" → Source is "GitHub Actions"
2. Verify workflow completed successfully
3. Check artifact was uploaded: `actions/upload-pages-artifact`
4. Verify `website/static/index.html` exists

**HTML files missing**:
```bash
# Verify all files exist
cd website/static
ls -la *.html  # Should show: index.html, features.html, docs.html, blog.html, contact.html
ls -la css/    # Should show: style.css
ls -la js/     # Should show: main.js
```

**CSS or JS not loading**:
1. Check file paths in HTML are correct: `/css/style.css` and `/js/main.js`
2. Verify files exist in `website/static/` directory
3. Check file permissions are readable

**Domain not resolving**:
1. Ensure `CNAME` file exists in `website/static/`
2. DNS records properly configured
3. Repository allows custom domains

**Workflow validation errors**:
1. Check workflow logs for specific errors
2. Verify HTML files have closing tags (`</html>`, `</body>`)
3. Ensure CSS and JS files are referenced in HTML
4. Run validation locally: `cd website/static && ls -la`

### Authentication Failures

Verify credentials in GitHub repository settings:
1. Settings → Secrets and variables → Actions
2. Check all required secrets are present
3. Verify secret values are current
4. Check IAM permissions for service accounts

### State Lock Issues

If state is locked from previous run:
```bash
# Manually unlock (use with caution)
aws dynamodb delete-item --table-name terraspan-locks \
  --key '{"LockID":{"S":"aws/dev/terraform.tfstate"}}'
```

### GitHub Pages Permissions

Ensure workflow has proper permissions:
```yaml
permissions:
  contents: read
  pages: write
  id-token: write
###Hugo GitHub Pages Action](https://github.com/peaceiris/actions-hugo)
- [Deploy Pages Action](https://github.com/actions/deploy-pages)
- [TerraSpan CI/CD Guide](../../docs/cicd.md)
- [Deployment Guide](../../docs/deployment.md)
- [Website Guide](../../website/README
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
