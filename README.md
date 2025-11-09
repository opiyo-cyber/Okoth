****Kubernetes Week 5 Independent Project (AWS EKS Deployment)**

This project demonstrates the deployment of a containerized multi-service application onto Amazon Elastic Kubernetes Service (EKS). The objective of this Independent Project was to apply Kubernetes orchestration concepts — such as Deployments, Services, Persistent Volumes, and StatefulSets — to deploy and manage a distributed application on a cloud-based cluster.

**Project Overview**

Building upon the Week 2 Independent Project, this stage focused on deploying the same Dockerized application to a managed Kubernetes cluster on AWS EKS.

Each service of the application was packaged into a Docker image, pushed to Docker Hub with proper tagging conventions, and orchestrated using Kubernetes YAML manifests.

The final deployment exposes a live, publicly accessible application through an AWS-managed Elastic Load Balancer (ELB).

**Architecture Overview**

**Core components:**

Frontend Service – A lightweight UI served using Nginx.

Backend API – RESTful API implemented using Node.js/Express

Database – PostgreSQL deployed as a StatefulSet with persistent volume claims for stable storage.

Persistent Storage – Backed by AWS Elastic Block Store (EBS) volumes.

Kubernetes Services – Internal communication via ClusterIP; external exposure via LoadBalancer.

 **Deployment Details**
 
Kubernetes Objects Used
Object	Purpose	Description
Deployment	Application management	used for stateless services, such as the frontend and backend, to handle scaling and rolling updates.
StatefulSet	Database management	Deployed PostgreSQL with stable network identities and persistent storage.
PersistentVolumeClaim (PVC)	Data storage	ensures that database data persists across pod restarts or node failures.
Service (ClusterIP)	Internal routing	facilitates communication between frontend, backend, and database.
Service (LoadBalancer)	External exposure	Creates an AWS ELB to route public internet traffic to the frontend.

**Live URL:**

http://a263a87fb0806478fb57ecdd53f82e49-973885211.us-east-1.elb.amazonaws.com:3000

**Persistent Storage**

The database uses PersistentVolumeClaims (PVCs) backed by AWS EBS volumes.
This guarantees durable and reliable data storage across pod rescheduling or restarts.

Example storage snippet:

volumeMounts:
  - name: db-storage
    mountPath: /var/lib/postgresql/data
volumes:
  - name: db-storage
    persistentVolumeClaim:
      claimName: postgres-pvc


AWS automatically provisions the EBS volume when the PVC is created, providing scalable and fault-tolerant storage for the StatefulSet.

**Git Workflow**

The following workflow was used to manage development and deployment:

Main branch – Stable and production-ready manifests.

Feature branches – For developing and testing specific Kubernetes objects (e.g., feature/statefulset-db).

Commit messages – Clear, descriptive commit messages following conventional commit standards.

Pull requests – Used to merge tested updates into main.

**Docker Image Management**

Docker images for each service were built, tagged, and pushed to Docker Hub for accessibility by the EKS cluster.

Consistent naming and semantic tagging ensure clear version control and image identification across deployments.


**Final Deliverables******
Deliverable	Description

**Application URL**

http://a263a87fb0806478fb57ecdd53f82e49-973885211.us-east-1.elb.amazonaws.com:3000

**Explanation.md**	   contains detailed explanations for Kubernetes object selection, exposure method, and storage setup.

**References**

Kubernetes Documentation

Amazon EKS User Guide

Docker Hub

StatefulSets Overview

AWS EBS Persistent Volumes

**Author**

**Your Name**
opiyo-cyber

**GitHub Profile**
https://github.com/opiyo-cyber
