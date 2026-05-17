# Serverless URL Shortener - Infrastructure

This repository contains the Terraform configuration needed to provision the cloud infrastructure for the serverless URL shortener on AWS. It handles everything from the routing layer down to the database and security configurations.

## Prerequisites

Before running this code or setting up the GitHub Actions pipeline, you must set up the following in your AWS account:

1.  **Terraform State Bucket:** Create an S3 bucket in AWS to store your Terraform state files. You will reference this bucket in your `dev.tfbackend` and `prod.tfbackend` files.
2.  **GitHub OIDC Provider:** Create an Identity Provider in AWS IAM for GitHub Actions.
3.  **Infrastructure IAM Role:** Create an IAM role that trusts the GitHub OIDC provider and attach the policy below. This policy gives Terraform just enough access to create and manage the necessary resources without using full administrator access.
4. Click **New repository variable** and add the following:
   * `AWS_INFRA_ROLE_ARN`: The ARN of the AWS IAM Role you created for infrastructure deployment (e.g., `arn:aws:iam::123456789012:role/GitHubActions-InfraRole`).
   * `AWS_REGION`: Your target AWS deployment region (e.g., `us-east-1`).

### Infrastructure IAM Policy (Least Privilege)
Replace `<ACCOUNT_ID>` and `<REGION>` with your actual AWS details.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ManageCoreComputeAndStorage",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket", "s3:DeleteBucket", "s3:PutBucket*", "s3:GetBucket*", "s3:ListBucket", "s3:PutObject", "s3:GetObject", "s3:DeleteObject",
                "dynamodb:CreateTable", "dynamodb:DeleteTable", "dynamodb:UpdateTable", "dynamodb:DescribeTable", "dynamodb:ListTables", "dynamodb:TagResource", "dynamodb:UntagResource", "dynamodb:DescribeTimeToLive",
                "lambda:CreateFunction", "lambda:DeleteFunction", "lambda:UpdateFunctionCode", "lambda:UpdateFunctionConfiguration", "lambda:GetFunction*", "lambda:List*", "lambda:AddPermission", "lambda:RemovePermission", "lambda:TagResource", "lambda:UntagResource"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageNetworkingAndEdge",
            "Effect": "Allow",
            "Action": [
                "apigateway:GET", "apigateway:POST", "apigateway:PUT", "apigateway:PATCH", "apigateway:DELETE",
                "cloudfront:CreateDistribution", "cloudfront:UpdateDistribution", "cloudfront:DeleteDistribution", "cloudfront:GetDistribution*", "cloudfront:List*", "cloudfront:TagResource", "cloudfront:UntagResource", "cloudfront:CreateOriginAccessControl", "cloudfront:DeleteOriginAccessControl", "cloudfront:GetOriginAccessControl"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageIAMAndLogs",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole", "iam:DeleteRole", "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:GetRole*", "iam:List*", "iam:PassRole", "iam:TagRole", "iam:UntagRole",
                "logs:CreateLogGroup", "logs:DeleteLogGroup", "logs:PutRetentionPolicy", "logs:DescribeLogGroups", "logs:ListTagsLogGroup", "logs:TagResource", "logs:UntagResource"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowSSMForCloudFrontSecret",
            "Effect": "Allow",
            "Action": [
                "ssm:PutParameter", "ssm:GetParameter", "ssm:GetParameters", "ssm:DescribeParameters", "ssm:DeleteParameter", "ssm:AddTagsToResource", "ssm:ListTagsForResource"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageWAF",
            "Effect": "Allow",
            "Action": [
                "wafv2:CreateWebACL", "wafv2:GetWebACL", "wafv2:UpdateWebACL", "wafv2:DeleteWebACL", "wafv2:ListWebACLs", "wafv2:TagResource", "wafv2:UntagResource", "wafv2:ListTagsForResource", "wafv2:CheckCapacity", "wafv2:ListAvailableManagedRuleGroups"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowMonitoringResources",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricAlarm", "cloudwatch:DeleteAlarms", "cloudwatch:DescribeAlarms", "cloudwatch:TagResource", "cloudwatch:UntagResource",
                "sns:CreateTopic", "sns:DeleteTopic", "sns:GetTopicAttributes", "sns:SetTopicAttributes", "sns:ListTagsForResource", "sns:TagResource", "sns:UntagResource", "sns:Subscribe", "sns:Unsubscribe"
            ],
            "Resource": "*"
        }
    ]
}
```

### Directory Structure

```.github/workflows/terraform.yml```: The CI/CD pipeline definition for GitHub Actions.

```terraform/```: The root directory for all infrastructure code.

```authorizer/ & lambda-placeholder/```: Source code for the custom API Gateway authorizer and placeholder code used during initial Lambda provisioning.

```*.tf```: Core Terraform configuration files split by service (e.g., apigateway.tf, dynamodb.tf, cloudfront.tf, waf.tf).

```dev.tfbackend & prod.tfbackend```: Configuration files pointing to the specific S3 state locations for each environment.

```dev.tfvars & prod.tfvars```: Environment-specific variable values.

#### Deployment Flow
We use a two-environment setup (dev and prod). The deployment is completely automated via GitHub Actions.

**Pull Requests**: When you open a pull request targeting the dev or prod branch, GitHub Actions will run a terraform plan so you can review the intended changes before merging.

**Merging**: When code is merged into the dev or prod branch, the pipeline runs terraform apply using the corresponding backend and variable files for that environment.

### Running Locally
If you need to test changes from your local machine, navigate to the terraform directory and run:

```bash
# Initialize for the dev environment
terraform init -backend-config="dev.tfbackend"

# Plan changes
terraform plan -var-file="dev.tfvars"

# Apply changes
terraform apply -var-file="dev.tfvars"
```
