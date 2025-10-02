import os
from datetime import datetime
from pathlib import Path
from cosmos import LoadMode
from cosmos.airflow.dag import DbtDag
from cosmos.config import ProfileConfig, ProjectConfig, RenderConfig

DBT_PROJECT_PATH = Path(__file__).parent / "dbt_trino"

profile_config = ProfileConfig(
    profile_name="dbt_trino",
    target_name="trino_output",
    profiles_yml_filepath=str(DBT_PROJECT_PATH / "profiles.yml"),
)

basic_cosmos_dag_full_module_path_imports = DbtDag(
    project_config=ProjectConfig(
        DBT_PROJECT_PATH,
        manifest_path=DBT_PROJECT_PATH / "target/manifest.json",
        install_dbt_deps=False,
    ),
    profile_config=profile_config,
    operator_args={
        "install_deps": False,  # install any necessary dependencies before running any dbt command
        "full_refresh": False,  # used only in dbt commands that support this flag
    },
    render_config = RenderConfig(
        load_method=LoadMode.DBT_MANIFEST,
    ),
    schedule=None,
    start_date=datetime(2025, 10, 1),
    catchup=False,
    dag_id="basic_cosmos_dag",
    default_args={"retries": 0},
)
