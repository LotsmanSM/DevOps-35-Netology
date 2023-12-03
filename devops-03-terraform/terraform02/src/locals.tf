locals {
  project = "netology-develop-platform"
  env_web = "web"
  env_db = "db"
  vm_web_instance_name = "${local.project}-${local.env_web}"
  vm_db_instance_name = "${local.project}-${local.env_db}"

  env_develop    = "develop"
  env_stage      = "stage"
  env_production = "production"
  vm_develop_instance_name = "${local.project}-${local.env_develop}"
  vm_stage_instance_name = "${local.project}-${local.env_stage}"
  vm_production_instance_name = "${local.project}-${local.env_production}"
}