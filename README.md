Just a sample hello world application using Java/Spring Boot# Build-a-CI-CD-Pipeline-with-Docker-and-AWS
A guided DevOps project demonstrating how to build and automate a complete CI/CD pipeline using Docker, GitHub Actions, and AWS. The project containerizes a Spring Boot application, automates Docker image builds and pushes to AWS Elastic Container Registry (ECR), and deploys the application on AWS EC2 using Docker Compose.

# CI/CD Pipeline with Docker, GitHub Actions, AWS ECR, and EC2

This repository documents the complete guide followed while learning how to build automated deployment pipelines using Docker, AWS, and GitHub Actions.

This includes:
- [The main tutorial](https://github.com/Dhananjayak24/CICD_excercise) (Spring Boot application deployment)
- [The cumulative practice task](https://github.com/Dhananjayak24/nodejs-aws-cicd-pipeline) (Node.js deployment pipeline)

The goal of both projects is to automate the end-to-end deployment process from code commits to running applications on EC2 using Docker images stored in AWS ECR.

---

## SECTION 1: Main Tutorial Overview

The main guided project demonstrates how to deploy a Spring Boot application using Docker, AWS ECR, and GitHub Actions.

Topics covered include:
- Containerizing the Spring Boot application using Dockerfile and Docker Compose
- Automating CI pipeline to build Docker images
- Pushing images to AWS ECR
- Setting up EC2 with IAM role to pull images
- Deploying automatically using GitHub Actions over SSH

---

## SECTION 2: Steps for the Main Tutorial (Spring Boot Application)

### Step 1: Setup Project and Git Repository

Download project files from Coursera and place them in the desired directory.

```sh
git init
git config user.name
git remote add origin git@github.com:Dhananjayak24/CICD_excercise.git
git checkout -b main
git checkout -b dev
```
Switch to VS Code and ensure Docker Desktop is running.

### Step 2: Start Containers Locally
```
docker compose up
```

This verifies the app works before deployment.

### Step 3: Create AWS ECR Repository
- AWS Console:

- Search "ECR"

- Create repository: coursera/vue-docker

- Use default settings

Commit and push:
```
git add .
git commit -m "chore: initial commit"
git switch main
git merge dev
git push origin main

```
### Step 4: Configure IAM User for GitHub Actions

AWS Console:

- IAM → Users → Create user

- Name: GitHub-vue-user

- Attach policy: AmazonEC2ContainerRegistryFullAccess

Create access keys:

- Choose "Command Line Interface (CLI)"

- Copy Access Key and Secret Key

### Step 5: Add GitHub Secrets

Go to:
Repository → Settings → Secrets and Variables → Actions

Add the following:

| Name                  | Value                                         |
| --------------------- | --------------------------------------------- |
| AWS_ACCESS_KEY_ID     | From IAM user                                 |
| AWS_SECRET_ACCESS_KEY | From IAM user                                 |
| ECR_REPO              | URI from ECR                                  |
| AWS_REGION            | From repository URL (example: ap-southeast-2) |

## Step 6: Create GitHub CI Workflow

Create:
```
.github/workflows/ci.yml
```

Add:

```
name: CI push to ECR pipeline

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  docker-build-push:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Amazon ECR Login
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build docker image
        run: docker build -t ${{ secrets.ECR_REPO }}:latest .

      - name: Push docker image to Amazon ECR
        run: docker push ${{ secrets.ECR_REPO }}:latest
```
Push to trigger pipeline:

```
git add .
git commit -m "enable CI"
git push origin main
```
To manually trigger again without changes:
```
git commit --allow-empty -m "trigger pipeline"
git push origin main
```
### Step 7: Configure EC2 Instance with IAM Role

Create IAM role:

- IAM → Roles → Create Role → EC2

- Add policy: AmazonEC2ContainerRegistryFullAccess

- Name: EC2-ECR-Access

Launch EC2:

- AMI: Ubuntu

- Attach role: EC2-ECR-Access

- Allow HTTP traffic

- Create key pair: Spring-boot-keys.pem

Move PEM to WSL and secure it:
```
cp /mnt/c/Users/dkula/Projects/CICD_project/Spring-boot-keys.pem ~/
chmod 400 ~/Spring-boot-keys.pem
ssh -i ~/Spring-boot-keys.pem ubuntu@<EC2_IP>
```
This avoids the error:
```
Permissions 0777 for key are too open
```
### Step 8: Install Docker + Dependencies on EC2

Copy script to instance:
```
scp -i ~/Spring-boot-keys.pem script.sh ubuntu@<IP>:~

```
Then inside EC2:
```
chmod +x script.sh
./script.sh
```
Test:
```
docker pull redis
```
### Step 9: Update GitHub Workflow for Deployment

Add to pipeline:
```
deploy:
  runs-on: ubuntu-latest
  needs: build
  steps:
    - name: Deploy via SSH to EC2
      uses: appleboy/ssh-action@v1.2.0
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ubuntu
        key: ${{ secrets.SSH_PRIVATE_KEY_EC2 }}
        script: |
          docker compose pull
          docker compose up -d --force-recreate
```
### Step 10: Create docker-compose.yml on EC2
```
version: "3.8"
services:
  app:
    image: 471112643709.dkr.ecr.ap-southeast-2.amazonaws.com/coursera/spring-boot-docker
    ports:
      - "80:80"
```
Push code again:
```
git push origin main
```
Once deployed successfully, open:
```
http://<EC2_PUBLIC_IP>/swagger-ui/index.html
```
## Key Learnings from Tutorial

#### Task 1: Containerizing application

- Dockerfile packages dependencies

- Docker Compose manages multi-container setup

#### Task 2: CI pipeline

- GitHub Actions builds Docker images automatically

#### Task 3: Push to AWS ECR

- ECR stores container builds securely

- IAM permissions required

#### Task 4: Practice reinforcement

- Apply same steps to new app

#### Task 5: EC2 Deployment

- IAM roles allow instance to pull from ECR

- Docker Compose runs application on EC2

## Troubleshooting Issues

| Issue                             | Cause                      | Fix                     |
| --------------------------------- | -------------------------- | ----------------------- |
| Permissions too open for .pem     | File in Windows filesystem | Move to WSL + chmod 400 |
| docker buildx requires 1 argument | Space between `$` and `{{` | Remove space            |
| unknown instruction CMD[`npm`     | Missing space after CMD    | CMD ["npm", "start"]    |
| docker-compose not found          | Using Compose v2           | Use `docker compose`    |

## Practice Task Summary (Node.js CI/CD)

The cumulative task repeats same flow for a Node.js app:

- Dockerize app

- Push image to ECR

- Deploy via SSH using GitHub Actions

- Use docker compose syntax

- Same IAM + EC2 workflow

Full walkthrough is documented in another [repository](https://github.com/Dhananjayak24/nodejs-aws-cicd-pipeline).
