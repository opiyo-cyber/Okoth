# YOLO E-Commerce Application - Docker Implementation Explanation

This document explains the design choices and implementation details for containerizing the YOLO e-commerce application using Docker and Docker Compose. It covers the key aspects required for the assignment objectives.

---

## 1. Choice of the Base Image on Which to Build Each Container

- **Frontend (`brian-yolo-client`)**  
  Used a multi-stage build:
  - **Build Stage:** `node:14-slim` — provides a full Node.js environment with necessary build tools while keeping image size reasonable.  
  - **Production Stage:** `alpine:3.16.7` — minimal Linux base to drastically reduce the final image size and surface area for vulnerabilities.

- **Backend (`brian-yolo-backend`)**  
  Also a multi-stage build:
  - **Build Stage:** `node:14` — full Node.js for installing dependencies and building the app.  
  - **Production Stage:** `alpine:3.16.7` — minimal runtime environment for running the backend server efficiently.

- **Database (`app-ip-mongo`)**  
  Used the official `mongo:latest` image to leverage a well-maintained, production-ready MongoDB instance.

---

## 2. Dockerfile Directives Used in Creation and Running of Each Container

- **`FROM`**: Defines the base image and supports multi-stage builds to separate build environment from runtime.
- **`WORKDIR`**: Sets a consistent working directory inside the container.
- **`COPY`**: Transfers necessary files (code, dependencies) into the container.
- **`RUN`**: Installs dependencies like `npm install` or system packages via Alpine’s `apk`.
- **`EXPOSE`**: Documents the port on which the containerized service runs.
- **`CMD`**: Specifies the default command to start the application.
- **Multi-stage builds**: Used to reduce final image size by excluding build tools from the runtime image.

---

## 3. Docker-compose Networking

- Configured a **custom bridge network (`app-net`)** for inter-container communication.
- Network uses a dedicated subnet `172.24.0.0/16` to avoid conflicts.
- Containers communicate using service names (e.g., backend can access database via hostname `app-ip-mongo`).
- Ports are mapped as follows to avoid conflicts on the host machine:
  - Frontend: `3002` (host) → `3000` (container)
  - Backend: `5001` (host) → `5000` (container)
  - MongoDB: `27017` (host) → `27017` (container)

---

## 4. Docker-compose Volume Definition and Usage

- Defined a **named volume** (`app-mongo-data`) for MongoDB data persistence.
- The volume is mounted to `/data/db` inside the MongoDB container, ensuring that all database data persists across container restarts or updates.
- Using named volumes provides easier backup and migration options.

---

## 5. Git Workflow Used to Achieve the Task

- Cloned the starter repository and created feature branches for development.
- Followed atomic commits with clear and descriptive messages using a conventional format, for example:
  - `feat(backend): add MongoDB networking and volume configuration`
  - `fix(docker): resolve port conflict issues in docker-compose`
  - `docs: update explanation.md with Dockerfile rationale`
- Pushed changes regularly to GitHub with pull requests for peer review.
- Tagged commits corresponding to Docker image versions for traceability (e.g., `v1.0`).
- Used `.gitignore` and `.dockerignore` files to keep the repository clean and optimize Docker builds.
- Employed Docker Compose to build and test containers locally before pushing to the repository.

---

## 6. Successful Running of the Applications and Debugging Measures Applied

- The full stack application starts successfully with `docker-compose up --build`.
- Verified container health and logs using `docker-compose logs` and `docker ps`.
- Debugged common issues such as:
  - Port conflicts by adjusting mapped ports.
  - Dependency installation failures by refining Dockerfile instructions.
  - Network connectivity problems by ensuring correct service names and network setup.
- Rebuilt containers with `--build` flag after making Dockerfile changes.
- Validated data persistence by adding products through the frontend and verifying data remains after container restarts.

---

## 7. Good Practices Followed

- Used **semantic version tags** for Docker images with your Docker Hub username, for example:  
  - `opiyocrosh/brian-yolo-client:v1.0`  
  - `opiyocrosh/brian-yolo-backend:v1.0`  
- Created a dedicated Docker network to isolate and manage container communication.
- Used named volumes for persistent data storage.
- Employed `.dockerignore` to reduce build context and speed up builds.
- Maintained a clean and descriptive Git commit history.
- Documented all steps and architectural choices in this explanation file.

---

## Screenshot of DockerHub Deployed Image

![DockerHub Screenshot]<img width="1483" height="677" alt="Screenshot from 2025-10-14 01-43-30" src="https://github.com/user-attachments/assets/c1272c24-0a9d-46a1-ba27-7571c0c2ef89" />
<img width="1483" height="677" alt="Screenshot from 2025-10-14 01-44-02" src="https://github.com/user-attachments/assets/ef5f622c-1777-4408-84d0-48a0e54336ac" />


---

*End of explanation.md*
