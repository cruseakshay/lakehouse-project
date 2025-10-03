# 🏠 Lakehouse Project

## 📋 Table of Contents

- [Overview](#overview)
- [Technology Stack](#technology-stack)
- [Project Contents](#project-contents)
- [Local Deployment](#local-deployment)
- [Astronomer Deployment](#astronomer-deployment)
- [References](#references)

## 📖 Overview

This project is based on a blog post demonstrating a modern data stack with Airflow, dbt, Trino, MinIO, and Nessie: https://vutr.substack.com/p/build-a-lakehouse-on-a-laptop-with

This readme describes the contents of the project, as well as how to run Apache Airflow on your local machine.

This project was generated using `astro dev init` using the Astronomer CLI.

## 🛠️ Technology Stack

- **🎯 Orchestration**: Apache Airflow with Astronomer CLI
- **🔄 Data Transformation**: dbt Core with custom operators and astronomer-cosmos package
- **⚡ Query Engine**: Trino (distributed SQL analytics)
- **🗄️ Data Lake Storage**: MinIO (S3-compatible object storage)
- **📚 Data Catalog**: Nessie (Git-like data versioning)
- **🐳 Infrastructure**: Docker containerization with docker-compose

## 📁 Project Contents

This Airflow project contains the following files and folders:

- **`dags/`**: This folder contains the Python files for your Airflow DAGs.
- **`dags/dbt_trino/`**: This folder contains dbt project files for dbt-trino integration.
- **`Dockerfile`**: This file contains a versioned Astro Runtime Docker image that provides a differentiated Airflow experience. If you want to execute other commands or overrides at runtime, specify them here.
- **`include/`**: This folder contains any additional files that you want to include as part of your project. It is empty by default.
- **`packages.txt`**: Install OS-level packages needed for your project by adding them to this file. It is empty by default.
- **`requirements.txt`**: Install Python packages needed for your project by adding them to this file. It is empty by default.
- **`plugins/`**: Add custom or community plugins for your project to this file. It is empty by default.
- **`airflow_settings.yaml`**: Use this local-only file to specify Airflow Connections, Variables, and Pools instead of entering them in the Airflow UI as you develop DAGs in this project.

## 🚀 Local Deployment

### Getting Started

Start Airflow on your local machine by running:

```bash
just start
```

### Docker Containers

This command will spin up **five Docker containers** on your machine, each for a different Airflow component:

#### Airflow Components
- **Postgres**: Airflow's Metadata Database
- **Scheduler**: The Airflow component responsible for monitoring and triggering tasks
- **DAG Processor**: The Airflow component responsible for parsing DAGs
- **API Server**: The Airflow component responsible for serving the Airflow UI and API
- **Triggerer**: The Airflow component responsible for triggering deferred tasks

#### Lakehouse Infrastructure
Additionally, the following containers will be started for the lakehouse infrastructure:

- **Nessie Catalog**: Data catalog service for managing data lake metadata (port `19120`)
- **MinIO**: S3-compatible object storage for the data lake (ports `9000`, `9001`)
- **Trino Coordinator**: Query engine coordinator for distributed SQL queries (port `8081`)
- **Trino Worker 1**: First worker node for the Trino query engine
- **Trino Worker 2**: Second worker node for the Trino query engine

### Access Points

When all containers are ready the command will open the browser to the Airflow UI at http://localhost:8080/.

You should also be able to access your Postgres Database at `localhost:5432/postgres` with:
- **Username**: `postgres`
- **Password**: `postgres`

> **Note**: If you already have either of the above ports allocated, you can either [stop your existing Docker containers or change the port](https://www.astronomer.io/docs/astro/cli/troubleshoot-locally#ports-are-not-available-for-my-local-airflow-webserver).

## ☁️ Astronomer Deployment

If you have an Astronomer account, pushing code to a Deployment on Astronomer is simple. For deploying instructions, refer to Astronomer documentation: https://www.astronomer.io/docs/astro/deploy-code/

## 📚 References

- [Astronomer CLI](https://www.astronomer.io/docs/astro/cli/)
- [Astro Runtime](https://www.astronomer.io/docs/runtime/runtime-image-architecture)
- [Airflow Documentation](https://airflow.apache.org/docs/)
- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [Trino Documentation](https://trino.io/docs/current/)
- [MinIO Documentation](https://docs.min.io/)
- [Nessie Documentation](https://projectnessie.org/)
- [Astronomer Cosmos](https://astronomer.github.io/astronomer-cosmos/)
