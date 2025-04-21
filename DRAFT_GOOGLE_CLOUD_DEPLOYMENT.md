
# TAG App – Google Cloud Run Deployment Guide

This guide documents how to deploy the TAG application to **Google Cloud Run**, leveraging:
- `Dockerfile` for building the app container
- `cloudbuild.yaml` for CI/CD automation with Google Cloud Build
- `docker-compose.yml` for optional local development
- Cloud SQL (PostgreSQL) for the production database

## Prerequisites

- Access to a Google Cloud project with billing enabled
- Permissions to manage:
  - Cloud Build
  - Cloud Run
  - Artifact Registry
  - Cloud SQL
  - Secret Manager
- A GitHub repository containing this project

## Clone the Repo

```bash
git clone https://github.com/YOUR_ORG/YOUR_REPO.git
cd YOUR_REPO
```

## Enable Google Cloud APIs

```bash
gcloud services enable run.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  sqladmin.googleapis.com \
  secretmanager.googleapis.com
```

##  Set Up Cloud SQL (PostgreSQL)

1. Create a Cloud SQL instance (e.g. `tag-app-db`)
2. Create a database: `tag_app_production`
3. Create a user: `rails_user` with a strong password
4. Note the instance connection name: `PROJECT_ID:us-central1:tag-app-db`

## Store Required Secrets

```bash
echo -n "YOUR_SECRET_KEY_BASE" | gcloud secrets create secret-key-base --data-file=-
echo -n "YOUR_DB_PASSWORD" | gcloud secrets create db-password --data-file=-

gcloud secrets add-iam-policy-binding secret-key-base \
  --member="serviceAccount:$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')@cloudbuild.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding db-password \
  --member="serviceAccount:$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')@cloudbuild.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

## Push Docker Image to Artifact Registry

```bash
gcloud builds submit --region=global \
  --tag us-central1-docker.pkg.dev/YOUR_PROJECT_ID/spring2025-tag-repo/tag-app
```

## Deploy to Cloud Run

```bash
gcloud run deploy tag-app-service \
  --image us-central1-docker.pkg.dev/YOUR_PROJECT_ID/spring2025-tag-repo/tag-app \
  --region us-central1 \
  --platform managed \
  --add-cloudsql-instances=YOUR_PROJECT_ID:us-central1:tag-app-db \
  --set-env-vars=RAILS_ENV=production,RAILS_SERVE_STATIC_FILES=true \
  --set-secrets=SECRET_KEY_BASE=secret-key-base:latest,DB_PASSWORD=db-password:latest \
  --allow-unauthenticated
```

## Run Database Migrations and Seeds (optional)

Create and execute a Cloud Run job or run manually via terminal:

```bash
# If using Docker:
docker run --rm -v $PWD:/app -w /app ruby:3.2.1-alpine \
  sh -c "apk add --no-cache build-base postgresql-dev nodejs yarn && \
         bundle install && \
         RAILS_ENV=production DATABASE_URL=your_db_url_here bundle exec rails db:migrate db:seed"
```

Or run via Cloud Run Jobs if previously configured.

## CI/CD Automation (Optional but Recommended)

- A `cloudbuild.yaml` file is included to automate:
  - Docker build
  - Image push to Artifact Registry
  - Deployment to Cloud Run
- Set up a trigger in Cloud Build to deploy on every push to `main`

```yaml
options:
  logging: CLOUD_LOGGING_ONLY
```

## Deployment is Complete!

Visit your deployed app at:

```
https://YOUR_CLOUD_RUN_SERVICE_URL
```

## 🧹 Teardown Instructions (Optional)

If you need to shut down the environment:

```bash
gcloud run services delete tag-app-service --region=us-central1
gcloud sql instances delete tag-app-db --region=us-central1
gcloud artifacts repositories delete spring2025-tag-repo --location=us-central1
gcloud secrets delete secret-key-base
gcloud secrets delete db-password
```

## 📎 Notes for the Future Teams

- Update secret values before deployment
- Re-create Cloud SQL user/password and update secret
- Review and verify `cloudbuild.yaml` and `config/database.yml`
- Check that the deployed service is running via `gcloud run services list`
