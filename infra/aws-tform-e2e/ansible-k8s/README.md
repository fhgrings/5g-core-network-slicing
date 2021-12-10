
# K8S Single Cluster spinup
This is a project willing to summarize some of the DevOps topics.
## Used Tools
The main idea was to use as much tools as I could:

 - Docker
 - Ansible
 - Terraform
 - Drone CI
 - AWS
 - Kubernetes

## How does  it work?

- Terraform creates the 3 AWS instances, Security Group and a Keypair.
- Ansible installs and configure Kubernetes.
- They work together on a Drone CI pipeline.
- The Drone CI uses a Docker container that I have created with Terraform and Ansible there.

## The goal
The goal is just to setup a Kubernetes cluster within 3 AWS instances.
