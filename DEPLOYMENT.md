# Deployment Overview – GCP (Cloud Run + Cloud Build)

This project is deployed to **Google Cloud Run**, using **Cloud Build** to build and deploy directly from a Dockerfile. This doc outlines the current setup for quick reference by future devs.

---

## Source Repository
- Public GitHub Repo
- Deployment triggered on **push to `main` branch**

---

## CI/CD Pipeline (Cloud Build)
- **Trigger:** Push to `main`
- **Build config:** No `cloudbuild.yaml`; Cloud Build uses default `Dockerfile`
- **Secrets:** Managed via [Secret Manager](https://cloud.google.com/secret-manager)

### Build Flow
1. Cloud Build pulls latest code from GitHub
2. Builds Docker image from root `Dockerfile`
3. Deploys to Cloud Run (see below)

---

## Dockerfile (Build Info)
- **Base Image:** `ruby:3.2.1-alpine`
- **App Type:** Ruby on Rails (with frontend assets via Yarn)
- **System Packages Installed:**
  - `build-base`, `nodejs`, `yarn`, `imagemagick`, `postgresql-dev`
- **Build Steps:**
  1. Installs gems via `bundle install` (excluding dev/test groups)
  2. Installs frontend dependencies via `yarn install --production`
  3. Precompiles assets with `bundle exec rake assets:precompile`
- **Exposed Port:** `8080`
- **Entrypoint:**  
  `rails server -b 0.0.0.0 -p 8080 -e development`

> Note: The container runs in **development mode**. Consider switching to `production` mode in Cloud Run.

---

## Cloud Run Service
- **Region:** `YOUR_REGION_HERE`
- **Visibility:** Public (unauthenticated access)
- **Deployment:** Automatically deployed after successful Cloud Build
- **Container Port:** `8080` (exposed in Dockerfile)

---

## Secrets & IAM
- **Secrets stored in GCP Secret Manager**
  - Accessed via environment variables at runtime
- **IAM Roles Used:**
  - Cloud Build: `roles/cloudbuild.builds.editor`
  - Cloud Run Service Account:
    - `roles/run.invoker`
    - `roles/secretmanager.secretAccessor`
  - Follows principle of **least privilege**

---

## Monitoring / Logging
_(Placeholder)_
- Logs viewable in **Cloud Logging**
- Consider setting up alerting and dashboards via **Cloud Monitoring**

---

## Notes
- Deployment is fully automated — no manual steps
- Ensure secrets are properly configured in Secret Manager before triggering a build

---

## Future Enhancements _(Optional)_
- Add staging environment
- Add traffic splitting or canary deploys
- Monitor error rates & autoscaling configs
