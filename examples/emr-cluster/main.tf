# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY An AMAZON EMR CLUSTER WITH EC2 INSTANCES AS WORKERS
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # This module isn't compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

# ------------------------------------------------------------------------------
# CONFIGURE THE AWS PROVIDER
# ------------------------------------------------------------------------------

provider "aws" {
  version = "~> 2.28"

  region = var.aws_region
}

module emr_cluster {
  source = "../../modules/emr-cluster"

  cluster_name = var.cluster_name
  custom_tags  = var.custom_tags

  vpc_id       = data.aws_vpc.default.id
  subnet_type  = "public"
  subnet_id    = sort(data.aws_subnet_ids.default.ids)[0]

  release_label = var.release_label

  termination_protection = var.termination_protection

  keep_job_flow_alive_when_no_steps = var.keep_job_flow_alive_when_no_steps
  ebs_root_volume_size              = var.ebs_root_volume_size
  custom_ami_id                     = var.custom_ami_id
  visible_to_all_users              = var.visible_to_all_users

  applications = var.applications

  core_instance_group_instance_type            = var.core_instance_group_instance_type
  core_instance_group_instance_count           = var.core_instance_group_instance_count
  core_instance_group_ebs_size                 = var.core_instance_group_ebs_size
  core_instance_group_ebs_type                 = var.core_instance_group_ebs_type
  core_instance_group_ebs_iops                 = var.core_instance_group_ebs_iops
  core_instance_group_ebs_volumes_per_instance = var.core_instance_group_ebs_volumes_per_instance
  core_instance_group_bid_price                = var.core_instance_group_bid_price
  core_instance_group_autoscaling_policy       = var.core_instance_group_autoscaling_policy

  master_instance_group_instance_type            = var.master_instance_group_instance_type
  master_instance_group_instance_count           = var.master_instance_group_instance_count
  master_instance_group_bid_price                = var.master_instance_group_bid_price
  master_instance_group_ebs_size                 = var.master_instance_group_ebs_size
  master_instance_group_ebs_type                 = var.master_instance_group_ebs_type
  master_instance_group_ebs_iops                 = var.master_instance_group_ebs_iops
  master_instance_group_ebs_volumes_per_instance = var.master_instance_group_ebs_volumes_per_instance

  scale_down_behavior    = var.scale_down_behavior
  additional_info        = var.additional_info
  configurations_json    = var.configurations_json
  security_configuration = var.security_configuration

  bootstrap_action = var.bootstrap_action

  # no logging needed for testing
  s3_log_uri = null

  create_task_instance_group                   = var.create_task_instance_group
  task_instance_group_instance_type            = var.task_instance_group_instance_type
  task_instance_group_instance_count           = var.task_instance_group_instance_count
  task_instance_group_ebs_size                 = var.task_instance_group_ebs_size
  task_instance_group_ebs_type                 = var.task_instance_group_ebs_type
  task_instance_group_ebs_iops                 = var.task_instance_group_ebs_iops
  task_instance_group_ebs_volumes_per_instance = var.task_instance_group_ebs_volumes_per_instance
  task_instance_group_bid_price                = var.task_instance_group_bid_price
  task_instance_group_ebs_optimized            = var.task_instance_group_ebs_optimized
  task_instance_group_autoscaling_policy       = var.task_instance_group_autoscaling_policy
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THIS EXAMPLE IN THE DEFAULT VPC AND SUBNETS
# To keep this example simple, we deploy it in the default VPC and subnets. In real-world usage, you'll probably want
# to use a custom VPC and private subnets.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_caller_identity" "current" {}
