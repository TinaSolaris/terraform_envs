# Elastic Beanstalk and Fargate
This project aims to create a certain AWS infrastructures via Terraform (infrastructure as code). Using Elastic Beanstalk or Elastic Container Service (Fargate) the application that consists of separate backend and frontend parts is deployed. Code of application is stored in the Docker images, which are located in the Elastic Container Registry.

For demonstration of how the images are created, the frontend source code with Dockerfile and entrypoint.sh are present in this GitHub repo.
The backend is a Spring Boot application - a simple Tic-Tac-Toe game.
The key point in the frontend image is that when it's created - it's not yet "aware" of the IP address (for Fargate) or domain name (for Beanstalk) of the backend. At the beginning it has a placeholder for this, and at the run time a certain value is retrieved via an environment variable, which is set using Terraform.

## Environment architecture

Diagrams of the developed infrastructure.

### Elastic Beanstalk

![Sample image](img/beanstalk/Beanstalk_diagram.png)

### Elastic Container Service (Fargate)

![Sample image](img/fargate/Fargate_diagram.png)

## Preview

Screenshots of configured AWS services and screenshots of running application.

### Elastic Beanstalk

Applications
![Sample image](img/beanstalk/Apps.png)

Environments
![Sample image](img/beanstalk/Envs.png)

Backend Environment
![Sample image](img/beanstalk/Back_env.png)

Frontend Environment
![Sample image](img/beanstalk/Front_env.png)

Instances
![Sample image](img/beanstalk/Instances.png)

Working Application
![Sample image](img/beanstalk/App.png)

### Elastic Container Service (Fargate)

Cluster
![Sample image](img/fargate/Cluster_g.png)

Cluster Details
![Sample image](img/fargate/Cluster_d.png)

Backend Service
![Sample image](img/fargate/Back_service.png)

Backend Task
![Sample image](img/fargate/Back_task.png)

Backend Service
![Sample image](img/fargate/Front_service.png)

Frontend Task
![Sample image](img/fargate/Front_task.png)

Working Application
![Sample image](img/fargate/App.png)
