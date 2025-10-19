# 🐳 YOLO E-Commerce App – Dockerized Full-Stack Application

This is a fully containerized full-stack e-commerce web application built using **React (frontend)**, **Node.js + Express (backend)**, and **MongoDB (database)**. The entire stack is managed using **Docker** and **Docker Compose** for seamless deployment and scalability.

The application allows users to add and view retail products. All product data is stored in MongoDB, with persistence managed via Docker volumes.

---

## 📦 Project Overview

This project demonstrates:

- Full-stack application containerization using Docker.
- Service orchestration using Docker Compose.
- MongoDB data persistence through Docker volumes.
- A modular architecture with separate containers for the frontend, backend, and database.

---

## 🛠 Tech Stack

- **Frontend:** React
- **Backend:** Node.js, Express
- **Database:** MongoDB
- **Containerization:** Docker & Docker Compose
- **Virtualization (optional):** Vagrant

---

Application Access
Component	URL
Frontend	http://localhost:3002

Backend	http://localhost:5001

Database	Internal (MongoDB container)
Docker Compose Overview

docker-compose.yml includes:

frontend: React app running on port 3002.

backend: Express API server running on port 5001.

mongo: MongoDB service with a named volume for data persistence.
Screenshots
<img width="1800" height="1035" alt="image" src="https://github.com/user-attachments/assets/f0aa5de1-3cbf-4071-b945-d3ec3ecb7c38" />

Author

GitHub: opiyo-cyber

DockerHub: https://hub.docker.com/repositories/opiyocrosh
