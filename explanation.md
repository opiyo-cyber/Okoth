# Explanation of Playbook Design and Execution Order

This document explains the sequencing, roles, and module choices in the Ansible-based automation, along with how Stage 2 orchestrates Terraform.

## Execution Order (Stage 1)
The main playbook `playbook.yml` runs roles in this sequence:

1) common
- Purpose: Bootstrap the host with Docker and prerequisites.
- Why first: All subsequent roles require Docker and Git.
- Key modules:
  - apt: install system packages and docker.io
  - systemd: enable and start docker
  - user: add vagrant to docker group for non-root usage
  - pip: install docker SDK and docker-compose

2) app_repo
- Purpose: Prepare application code on the host.
- Why second: Containers may need build contexts (Dockerfiles) and assets.
- Key modules:
  - file: create base directory and ensure correct ownership
  - git: clone the application repository at the specified version

3) database
- Purpose: Start the persistence layer (Postgres or MongoDB) with a named volume.
- Why third: Backend should discover a ready DB before it starts.
- Key modules:
  - community.docker.docker_network: create a shared network for service discovery
  - community.docker.docker_volume: ensure persistent volume exists
  - community.docker.docker_container: run the DB container, publish ports, and attach to network

4) backend
- Purpose: Build and run the backend container configured to reach the DB.
- Why fourth: Depends on both Docker and the DB being healthy.
- Key modules:
  - community.docker.docker_image: build the backend image from the repo path
  - community.docker.docker_container: run backend on the shared network with env vars

5) frontend
- Purpose: Build and run the frontend container configured to reach the backend.
- Why fifth: Depends on backend port/URL being available.
- Key modules:
  - community.docker.docker_image: build the frontend image from the repo path
  - community.docker.docker_container: run frontend with env pointing to backend

## Blocks and Tags
- Each role uses a top-level block for logical grouping and easier error isolation.
- Tags are assigned per role: common, app/repo, db, backend, frontend, allowing targeted runs (e.g., `--tags db,backend`).

## Variables and Persistence
- Variables centralize configuration in `group_vars/all.yml`.
- Persistence: DB containers use named volumes (e.g., `okoth-postgres-data`, `okoth-mongo-data`). Data survives container restarts.
- Inter-container networking: A user-defined Docker network (`okoth-net`) lets backend resolve the DB by container name.
- Backend env:
  - Postgres: `DATABASE_URL`, `PG*` vars point to `okoth-postgres:5432`.
  - Mongo: `MONGO_URL`/`MONGODB_URI` point to `okoth-mongo:27017` with `authSource=admin`.
- Frontend env:
  - `API_URL`, `REACT_APP_API_URL`, `VITE_API_URL` point to `http://<vm_ip>:<backend_port>`.
  - Adjust if your app expects different variable names.

## Stage 2 (Terraform + Ansible)
- The Stage 2 playbook installs `community.general` and applies Terraform at `Stage_two/terraform/`.
- Terraform uses a `null_resource` with `local-exec` to run `vagrant up --provision`, invoking Stage 1 via `ansible_local`.
- After apply, the playbook verifies the frontend is reachable with `wait_for` and `uri`.
- Terraform state management:
  - `terraform.tfstate` is intended to be committed (no secrets included).
  - Backup state `terraform.tfstate.backup` and `.terraform/` are ignored via `.gitignore`.

## Assumptions and Customization
- Repository layout includes `backend/` and `frontend/` with Dockerfiles at the roots of each.
- If your app uses different env var names, set them in `group_vars/all.yml` under `backend_env` and `frontend_env`.
- Switch DB engine via `db_engine` (postgres|mongo).
