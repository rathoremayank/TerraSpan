# Contributing to TerraSpan

Thank you for your interest in contributing to TerraSpan! This document provides guidelines and instructions for contributing.

## Code of Conduct

We are committed to providing a welcoming and inspiring community for all. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

1. **Title**: Clear, descriptive bug title
2. **Description**: What you expected vs. what happened
3. **Steps to Reproduce**: Detailed steps to reproduce
4. **Environment**: 
   - Terraform version
   - Cloud provider and region
   - TerraSpan version
   - OS and browser (if applicable)
5. **Logs/Output**: Relevant error messages or logs

### Suggesting Enhancements

To suggest a feature:

1. **Use a clear title** describing the enhancement
2. **Provide detailed description** of the suggested enhancement
3. **Explain the use case** and why it would be useful
4. **List similar features** in other projects if applicable

### Code Contributions

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/terraspan.git
   cd terraspan
   git remote add upstream https://github.com/original-repo/terraspan.git
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make Your Changes**
   - Follow code style guidelines (see below)
   - Keep commits atomic and well-described
   - Add tests for new functionality
   - Update documentation as needed

4. **Test Locally**
   ```bash
   # Validate Terraform
   terraform validate
   terraform fmt -check -recursive
   
   # Run linting
   tflint --recursive infrastructure/
   
   # Run tests (if applicable)
   ./scripts/test.sh
   ```

5. **Commit Your Changes**
   ```bash
   git commit -m "feat: add amazing feature"
   ```

   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` A new feature
   - `fix:` A bug fix
   - `docs:` Documentation only changes
   - `style:` Changes that don't affect code meaning
   - `refactor:` Code refactoring
   - `perf:` Performance improvements
   - `test:` Adding or updating tests
   - `chore:` Build process, dependencies, etc.

6. **Push to Your Branch**
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Create a Pull Request**
   - Reference any related issues
   - Describe your changes clearly
   - Follow the PR template

## Code Style Guidelines

### Terraform

1. **Formatting**: Use `terraform fmt` (enforced by CI/CD)
   ```bash
   terraform fmt -recursive infrastructure/
   ```

2. **Variable Naming**: Use descriptive, lowercase names with underscores
   ```hcl
   # Good
   variable "vpc_cidr_block" { ... }
   
   # Bad
   variable "VPC" { ... }
   ```

3. **Resource Naming**: Follow `<cloud>_<type>_<purpose>` pattern
   ```hcl
   # Good
   resource "aws_security_group" "alb" { ... }
   
   # Bad
   resource "aws_security_group" "sg1" { ... }
   ```

4. **Comments**: Explain the "why", not the "what"
   ```hcl
   # Separate private and public subnets for security
   resource "aws_subnet" "private" { ... }
   ```

5. **Outputs**: Always include descriptions
   ```hcl
   output "vpc_id" {
     description = "The ID of the VPC"
     value       = aws_vpc.main.id
   }
   ```

### Documentation

1. **README Files**: Required for each module
2. **Inline Comments**: For complex logic
3. **Examples**: Include usage examples
4. **Line Length**: Wrap at 80 characters

### Git

1. **Commit Messages**: Start with type: `fix:` / `feat:` / `docs:` etc.
2. **Commit Size**: Keep commits focused and manageable
3. **Branch Names**: Use descriptive names: `feature/name`, `bugfix/issue-123`

## Testing

### Before Submitting

1. **Terraform Validation**
   ```bash
   terraform validate
   terraform fmt -check -recursive
   ```

2. **TFLint**
   ```bash
   tflint --recursive infrastructure/
   ```

3. **Checkov Security Scan**
   ```bash
   checkov -d infrastructure/ --framework terraform
   ```

4. **Manual Testing**
   ```bash
   # Create test plan
   terraform plan -out=testplan
   
   # Review plan carefully
   terraform show testplan
   
   # Clean up
   rm testplan
   ```

5. **Integration Tests** (if applicable)
   ```bash
   ./scripts/test.sh
   ```

## Documentation Standards

### Module Documentation

Each module must include:

1. **README.md** with:
   - Description of module purpose
   - List of resources created
   - Input variables documentation
   - Output variables documentation
   - Example usage

2. **Variable descriptions**: All variables must have descriptions
3. **Output descriptions**: All outputs must have descriptions

### Comment Standards

```hcl
# Use single line comments for resources

# This is a comment explaining the upcoming resource
resource "aws_instance" "web" {
  # Use inline comments for non-obvious configuration
  ami = var.ami_id
  
  tags = {
    Name = "web-server"
  }
}
```

## Pull Request Process

1. **Ensure Tests Pass**: All CI/CD checks must pass
2. **Update Documentation**: Update README and docs if needed
3. **Resolve Conflicts**: Merge main branch and resolve conflicts
4. **Request Review**: 2+ maintainers must approve
5. **Merge**: Squash merge into main branch

## Development Workflow

```bash
# 1. Sync with upstream
git fetch upstream
git rebase upstream/main

# 2. Create feature branch
git checkout -b feature/my-feature

# 3. Make changes and commit
git add .
git commit -m "feat: add new module"

# 4. Push and create PR
git push origin feature/my-feature
```

## Release Process

1. **Version Bump**: Update CHANGELOG and version
2. **Tag Release**: Create annotated git tag
3. **Release Notes**: Document changes and improvements
4. **Publish**: Push to main repository

## Getting Help

- **Documentation**: Check [docs/](docs/) directory
- **Issues**: Search existing GitHub issues
- **Discussions**: Use GitHub Discussions for questions
- **Email**: contact@terraspan.dev

## License

By contributing, you agree that your contributions will be licensed under the same Apache 2.0 license as the project.

## Recognition

Contributors will be recognized in:
- Project README (regular contributors)
- CONTRIBUTORS.md file
- Release notes
- Social media acknowledgment

---

**Thank you for contributing to TerraSpan!** 🚀
