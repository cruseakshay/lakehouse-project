# Lakehouse Project Management
# Manages Airflow + dbt + Trino + MinIO + Nessie services
# Default variables

ASTRO_CLI := "astro"
DOCKER_COMPOSE := "docker compose"
TRINO_CONTAINER := "trino-coordinator"
DBT_PROJECT_DIR := "dags/dbt_trino"

# Show available commands
default:
    @just --list

# Start all services (equivalent to start-all.sh)
start:
    @echo "🚀 Starting Airflow services..."
    {{ ASTRO_CLI }} dev start
    @echo "🗄️ Starting MinIO and Nessie services..."
    {{ DOCKER_COMPOSE }} -f docker-compose-override.yml up -d
    @echo "⏳ Waiting for services to be ready..."
    @sleep 15
    @echo "🏗️ Initializing Trino schemas..."
    @docker exec -it {{ TRINO_CONTAINER }} trino --catalog lakehouse --file /etc/trino/init.sql
    @echo "✅ All services started!"
    @just status

# Stop all services
stop:
    @echo "🛑 Stopping all services..."
    {{ ASTRO_CLI }} dev stop
    {{ DOCKER_COMPOSE }} -f docker-compose-override.yml down
    @echo "✅ All services stopped!"

# Restart all services
restart: stop start

# Show service status and URLs
status:
    @echo "📊 Service Status:"
    @echo "- Airflow UI: http://localhost:8080 (admin/admin)"
    @echo "- Trino Web UI: http://localhost:8081" 
    @echo "- MinIO Console: http://localhost:9001 (admin/password)"
    @echo "- MinIO API: http://localhost:9000"
    @echo "- Nessie Catalog: http://localhost:19120"

# Start only Airflow services
airflow-start:
    @echo "🚀 Starting Airflow services..."
    {{ ASTRO_CLI }} dev start

# Stop only Airflow services
airflow-stop:
    @echo "🛑 Stopping Airflow services..."
    {{ ASTRO_CLI }} dev stop

# Start only data services (MinIO + Nessie + Trino)
data-start:
    @echo "🗄️ Starting data services..."
    {{ DOCKER_COMPOSE }} -f docker-compose-override.yml up -d
    @echo "⏳ Waiting for services to be ready..."
    @sleep 15
    @echo "🏗️ Initializing Trino schemas..."
    @docker exec -it {{ TRINO_CONTAINER }} trino --catalog lakehouse --file /etc/trino/init.sql

# Stop only data services
data-stop:
    @echo "🛑 Stopping data services..."
    {{ DOCKER_COMPOSE }} -f docker-compose-override.yml down

# View Airflow logs
logs:
    {{ ASTRO_CLI }} dev logs

# Run dbt commands
dbt-deps:
    @echo "📦 Installing dbt dependencies..."
    @cd {{ DBT_PROJECT_DIR }} && dbt deps

dbt-seed:
    @echo "🌱 Running dbt seed..."
    @cd {{ DBT_PROJECT_DIR }} && dbt seed --profiles-dir . --project-dir .

dbt-run:
    @echo "🏃 Running dbt transformations..."
    @cd {{ DBT_PROJECT_DIR }} && dbt run --profiles-dir . --project-dir .

dbt-test:
    @echo "🧪 Running dbt tests..."
    @cd {{ DBT_PROJECT_DIR }} && dbt test --profiles-dir . --project-dir .

dbt-docs:
    @echo "📚 Generating dbt docs..."
    @cd {{ DBT_PROJECT_DIR }} && dbt docs generate --profiles-dir . --project-dir .
    @cd {{ DBT_PROJECT_DIR }} && dbt docs serve --profiles-dir . --project-dir .

# Full dbt pipeline (seed + run + test)
dbt-pipeline: dbt-seed dbt-run dbt-test

# Connect to Trino CLI
trino-cli:
    @echo "🔗 Connecting to Trino..."
    @docker exec -it {{ TRINO_CONTAINER }} trino --catalog lakehouse --schema staging

# View container logs
container-logs service:
    @docker logs -f {{ service }}

# Clean up everything (including volumes)
clean:
    @echo "🧹 Cleaning up all resources..."
    {{ ASTRO_CLI }} dev stop
    {{ ASTRO_CLI }} dev kill
    {{ DOCKER_COMPOSE }} -f docker-compose-override.yml down -v


# Check service health
health:
    @echo "🏥 Checking service health..."
    @curl -s http://localhost:8080/health 2>/dev/null && echo "✅ Airflow: Healthy" || echo "❌ Airflow: Unhealthy"
    @curl -s http://localhost:8081/v1/info 2>/dev/null && echo "✅ Trino: Healthy" || echo "❌ Trino: Unhealthy"
    @curl -s http://localhost:9000/minio/health/live 2>/dev/null && echo "✅ MinIO: Healthy" || echo "❌ MinIO: Unhealthy"
    @curl -s http://localhost:19120/api/v2/config 2>/dev/null && echo "✅ Nessie: Healthy" || echo "❌ Nessie: Unhealthy"

# Run Airflow DAG tests
test-dags:
    @echo "🧪 Testing DAGs..."
    {{ ASTRO_CLI }} dev pytest tests/

# Parse DAGs for syntax errors
parse-dags:
    @echo "🔍 Parsing DAGs..."
    {{ ASTRO_CLI }} dev parse

# Show project info
info:
    @echo "📋 Project Information:"
    @echo "- Project: lakehouse-project"
    @echo "- Airflow DAGs: $(ls dags/*.py | wc -l | tr -d ' ')"
    @echo "- dbt Models: $(find {{ DBT_PROJECT_DIR }}/models -name '*.sql' | wc -l | tr -d ' ')"
    @echo "- dbt Seeds: $(find {{ DBT_PROJECT_DIR }}/seeds -name '*.csv' | wc -l | tr -d ' ')"

# Quick development workflow
dev: start dbt-pipeline
    @echo "🎉 Development environment ready!"

