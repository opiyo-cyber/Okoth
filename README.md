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
   - Frontend: `http://192.168.56.10:3000/`
   - Backend (if directly browsable): `http://192.168.56.10:5000/`

## Stage 2 (Ansible orchestrating Terraform)
1) `cd Stage_two`
2) `ansible-playbook playbook.yml`
   - Applies Terraform, which invokes `vagrant up --provision`
   - Waits for the frontend and prints URL

## Persistence
- Postgres: named volume `okoth-postgres-data`
- Mongo: named volume `okoth-mongo-data`
- Data survives container restarts; removing the volume clears data

### Validate persistence (Mongo default)
1) Open the app at `http://192.168.56.10:3000/`
2) Add a product via the UI form
3) Restart backend container inside VM: `docker restart brian-yolo-backend`
4) Refresh products; the added product should still be present (persisted in `okoth-mongo-data`)

## Useful Tags
- Run specific parts: `vagrant provision --provision-with ansible_local -- --tags "db,backend"`
- Within VM (if running ansible locally): `ansible-playbook playbook.yml --tags backend`

## Git & Terraform State
- After running Stage 2, commit `Stage_two/terraform/terraform.tfstate` (contains no credentials in this setup)
- Ensure `Stage_two/terraform/terraform.tfstate.backup` and `.terraform/` remain ignored (see `.gitignore`)

## Push to GitHub
- Initialize and push:
  ```bash
  git init
  git add .
  git commit -m "Okoth: Stage 1 & Stage 2 provisioning"
  git branch -M main
  git remote add origin <your_repo_url>
  git push -u origin main
  ```

See `explanation.md` for detailed reasoning and module choices.
