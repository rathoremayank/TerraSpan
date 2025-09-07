#!/bin/bash

# Root project directory
PROJECT_ROOT="."

# Module names
MODULES=("network" "compute" "database" "security" "monitoring" "iam" "kubernetes" "storage")
# Environment names
ENVIRONMENTS=("dev" "staging" "prod")
# Files for modules
MODULE_FILES=("main.tf" "variables.tf" "outputs.tf")
# Files for environments
ENV_FILES=("main.tf" "variables.tf" "provider.tf" "terraform.tfvars")

# Create root project directory
mkdir -p $PROJECT_ROOT/modules
mkdir -p $PROJECT_ROOT/environments

# Create module directories and files
for module in "${MODULES[@]}"; do
  mkdir -p $PROJECT_ROOT/modules/$module
  for file in "${MODULE_FILES[@]}"; do
    touch $PROJECT_ROOT/modules/$module/$file
  done
done

# Create environment directories and files
for env in "${ENVIRONMENTS[@]}"; do
  mkdir -p $PROJECT_ROOT/environments/$env
  for file in "${ENV_FILES[@]}"; do
    touch $PROJECT_ROOT/environments/$env/$file
  done
done

# Create root-level files
touch $PROJECT_ROOT/README.md
touch $PROJECT_ROOT/versions.tf
touch $PROJECT_ROOT/.gitignore

echo "Terraform project structure created successfully in '$PROJECT_ROOT'"