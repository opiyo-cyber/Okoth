# Okoth - Stage 1 & Stage 2

Containerized e-commerce app deployment using Ansible (Stage 1) and Terraform+Ansible orchestration (Stage 2).

## Prerequisites
- VirtualBox and Vagrant
- Ansible (on your host for Stage 2 runner)
- Terraform (for Stage 2)

## Repo Structure
- `Vagrantfile` – boots Ubuntu 20.04 box and runs Ansible locally inside VM
- `playbook.yml` – Stage 1 main playbook (Ansible)
- `group_vars/all.yml` – central variables (edit me)
- `roles/` – roles: `common`, `app_repo`, `database`, `backend`, `frontend`
- `Stage_two/` – Stage 2: `playbook.yml` (Ansible) + `terraform/` module
- `explanation.md` – rationale for ordering, modules, and design

## Configure
Edit `group_vars/all.yml`:
- `app_repo_url`: your Week 2 repo URL
- `db_engine`: `postgres` (default) or `mongo`
- If needed, override `backend_env` and `frontend_env` to match your app's env var names

## Stage 1 (Ansible + Vagrant)
1) From this folder, run:
   - `vagrant up`
2) On success, open the app:
   - Frontend: `http://localhost:3002/
   - Backend (if directly browsable): `http://localhost:5001/

Alternative (Docker Compose on host):
- `docker compose up -d --build` (or `docker-compose ...`)
- Frontend: `http://localhost:3002` | Backend: `http://localhost:5001`
- Stop with: `docker compose down`

## Stage 2 (Ansible orchestrating Terraform)
1) `cd Stage_two`
2) `ansible-playbook playbook.yml`
   - Applies Terraform, which invokes `vagrant up --provision`
   - Waits for the frontend and prints the URL

## Persistence
- Postgres: named volume `okoth-postgres-data`
- Mongo: named volume `okoth-mongo-data`
- Data survives container restarts; removing the volume clears data

### Validate persistence (Mongo default)
1) Open the app at `http://localhost:3002`
2) Add a product via the UI form
3) Restart backend container inside VM: `docker restart brian-yolo-backend`
4) Refresh products; the added product should still be present (persisted in `okoth-mongo-data`)

## Useful Tags
- Run specific parts: `vagrant provision --provision-with ansible_local -- --tags "db,backend"`
- Within VM (if running Ansible locally): `ansible-playbook playbook.yml --tags backend`

## Git & Terraform State
- After running Stage 2, commit `Stage_two/terraform/terraform.tfstate` (contains no credentials in this setup)
- Ensure `Stage_two/terraform/terraform.tfstate.backup` and `.terraform/` remain ignored (see `.gitignore`)

Author

opiyo-cyber
email: opiyo20302030@gmail.com
GitHub Profile: https://github.com/opiyo-cyber

See `explanation.md` for detailed reasoning and module choices.
