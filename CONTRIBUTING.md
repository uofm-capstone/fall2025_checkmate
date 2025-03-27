## Development Workflow: Full Local Setup Commands
### 1. Build and Start Containers
Run this command in your project root (where docker-compose.yml is located):

`docker-compose up --build`

This will: 
- Build the Rails app container
- Start a PostgreSQL database container
- Start the Rails server on http://localhost:3000

### 2. Run Database Migrations
Once the containers are running, open a new terminal and run:

`docker-compose exec app bundle exec rails db:create db:migrate db:seed`

If the database already exists, ignore any "database exists" warnings.

### 3. Check Logs (Optional)
If you need to debug any issues, check container logs:

`docker-compose logs -f`

### 4. Access Rails Console
If you need to inspect your database or test queries:

`docker-compose exec app bundle exec rails console`
### 5. Stop Containers
To stop your running Rails app and database:

`docker-compose down`
This stops and removes containers but keeps your database data.

To delete all data and start fresh, add the `-v`flag:

`docker-compose down -v`

### 6 Restart Containers
If you’ve stopped your containers and want to restart them:

`docker-compose up`
No need to rebuild unless you change the Dockerfile.

### 7 Reset Database (If Needed)
If you need to completely reset your database:

docker-compose exec app bundle exec rails db:drop db:create db:migrate db:seed
