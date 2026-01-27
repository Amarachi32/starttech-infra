#!/bin/bash
set -e
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"