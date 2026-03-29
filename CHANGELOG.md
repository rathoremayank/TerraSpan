# Changelog

All notable changes to the TerraSpan project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure and documentation
- AWS module scaffolding (networking, compute, storage, IAM, monitoring)
- Azure module scaffolding (networking, compute, storage, IAM, monitoring)
- GCP module scaffolding (networking, compute, storage, IAM, monitoring)
- Environment-based configurations (dev, staging, prod)
- Remote state management documentation
- CI/CD workflows (validate, plan, apply)
- Static website with Hugo configuration
- Contributing guidelines
- Comprehensive documentation

### Changed
- (unreleased changes will be listed here)

### Deprecated
- (features being deprecated will be listed here)

### Removed
- (features being removed will be listed here)

### Fixed
- (bug fixes will be listed here)

### Security
- (security fixes will be listed here)

## [0.1.0] - 2026-03-29

### Added
- Project initialization
- Directory structure creation
- Initial README and documentation
- Cloud provider README files
- GitHub Actions workflow templates
- Website configuration with Hugo
- License and contribution guidelines

### Features
- Multi-cloud support scaffolding for AWS, Azure, GCP
- Modular Terraform structure
- Environment management framework
- Remote state configuration guide
- CI/CD integration templates

## Versioning Policy

We use Semantic Versioning: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes, structural overhaul
- **MINOR**: New features, new modules, backward compatible
- **PATCH**: Bug fixes, documentation, small improvements

---

## How to Contribute to Changelog

When submitting a pull request:

1. Add an entry to the `[Unreleased]` section
2. Use one of the following categories:
   - Added: for new features
   - Changed: for changes in existing functionality
   - Deprecated: for soon-to-be removed features
   - Removed: for removed features
   - Fixed: for any bug fixes
   - Security: for security improvements

3. Be concise and user-focused in descriptions
4. Reference issue numbers when applicable

### Example Entry

```markdown
### Added
- AWS RDS module with Multi-AZ support (#123)
- Automated backup retention policies

### Fixed
- State locking timeout issue in Azure backend (#124)
```

---

**Repository**: https://github.com/your-org/terraspan
**Documentation**: https://terraspan.dev/docs
**License**: Apache 2.0
