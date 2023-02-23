Task1. Automation challenge.

Develop a GCP deployment using Terraform and demonstrate the ability to build CI/CD pipelines in GitLab. You will have to create a free GCP account (if you don't already have one).

Part 1:

1. Create a new GCP account or use an existing one and create a project.
2. Set up the GCP Terraform provider on your local machine.
3. Define a VPC network and subnets in Terraform, along with firewall rules, IAM roles and permissions, and other resources that may be required for the landing zone.
4. Define a GKE cluster and its related resources in Terraform. Ensure that the cluster is private and has access to the landing zone network.
5. Use terraform init, terraform plan, and terraform apply to create the infrastructure in GCP.

Part 2:

1. Set up GitLab CE on GCP, either manually or using a Terraform module.
2. Clone the sample application from the GitHub repository onto your local machine.
3. Write a Dockerfile that packages the application into a Docker image.
4. Create a GitLab pipeline that builds the Docker image using the Dockerfile, and pushes the resulting image to the GitLab container registry.
5. Create a second GitLab pipeline that deploys the Docker image to the GKE cluster using Kubernetes manifests.
6. Ensure that the deployed application is production-ready and highly available.
