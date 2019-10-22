# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE AN ELASTIC MAPREDUCE (EMR) CLUSTER https://aws.amazon.com/emr/
# These templates launch an EMR cluster you can use for running various MapReduce jobs. The cluster includes:
# - Auto Scaling Group (ASG)
# - Launch configuration
# - Security group
# - IAM roles and policies
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# SET TERRAFORM REQUIREMENTS FOR RUNNING THIS MODULE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is only compatible with terraform >= 0.12
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
#  EMR MANAGED SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "managed_master" {
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = "${var.cluster_name}-managed-master"
  description            = "Master security group managed by AWS for an Elastic Mapreduce Cluster to dynamically add and remove rules based on your application set"
  tags                   = var.custom_tags

  # EMR will update "ingress" and "egress" so we ignore the changes here
  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }
}

resource "aws_security_group_rule" "managed_master_egress" {
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.managed_master.id
}

resource "aws_security_group" "managed_slave" {
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = "${var.cluster_name}-managed-slave"
  description            = "Slave security group managed by AWS for an Elastic Mapreduce Cluster to dynamically add and remove rules based on your application set"
  tags                   = var.custom_tags

  # EMR will update "ingress" and "egress" so we ignore the changes here
  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }
}

resource "aws_security_group_rule" "managed_slave_egress" {
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.managed_slave.id
}

# ---------------------------------------------------------------------------------------------------------------------
#  USER MANAGED SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "master" {
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = "${var.cluster_name}-master"
  description            = "Allow inbound traffic from Security Groups and CIDRs for masters. Allow all outbound traffic"
  tags                   = var.custom_tags
}

resource "aws_security_group_rule" "master_ingress_security_groups" {
  count = length(var.master_allowed_security_groups)

  description              = "Allow inbound traffic from Security Groups"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.master_allowed_security_groups[count.index]
  security_group_id        = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_ingress_cidr_blocks" {
  count             = length(var.master_allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.master_allowed_cidr_blocks
  security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_egress" {
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.master.id
}

resource "aws_security_group" "slave" {
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = "${var.cluster_name}-slave"
  description            = "Allow inbound traffic from Security Groups and CIDRs for slaves. Allow all outbound traffic"
  tags                   = var.custom_tags
}

resource "aws_security_group_rule" "slave_ingress_security_groups" {
  count = length(var.slave_allowed_security_groups)

  description              = "Allow inbound traffic from Security Groups"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.slave_allowed_security_groups[count.index]
  security_group_id        = aws_security_group.slave.id
}

resource "aws_security_group_rule" "slave_ingress_cidr_blocks" {
  count             = length(var.slave_allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.slave_allowed_cidr_blocks
  security_group_id = aws_security_group.slave.id
}

resource "aws_security_group_rule" "slave_egress" {
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.slave.id
}

resource "aws_security_group_rule" "master_to_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.master.id
}

resource "aws_security_group_rule" "slave_to_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.slave.id
  security_group_id        = aws_security_group.slave.id
}


resource "aws_security_group_rule" "master_to_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.slave.id
}

resource "aws_security_group_rule" "slave_to_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.slave.id
  security_group_id        = aws_security_group.master.id
}

# ---------------------------------------------------------------------------------------------------------------------
# MANAGED SERVICE SECURITY GROUP
# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html#emr-sg-elasticmapreduce-sa-private
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "managed_service_access" {
  count                  = var.subnet_type == "private" ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = "${var.cluster_name}-managed-service"
  description            = "Service access security group managed by AWS for an Elastic Mapreduce Cluster located in a private subnet to dynamically add and remove rules based on your application set"
  tags                   = var.custom_tags

  # EMR will update "ingress" and "egress" so we ignore the changes here
  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }
}

resource "aws_security_group_rule" "managed_service_access_egress" {
  count             = var.subnet_type == "private" ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = join("", aws_security_group.managed_service_access.*.id)
}


# ---------------------------------------------------------------------------------------------------------------------
#  IAM SERVICE ROLES FOR GRANTING AMAZON EMR PERMISSIONS TO AWS SERVICES AND RESOURCES
#  https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "assume_role_emr" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "emr_service_role" {
  name               = var.cluster_name
  path               = "/emr/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_emr.json
}

resource "aws_iam_role_policy_attachment" "emr_service_role" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

data "aws_iam_policy_document" "assume_role_ec2" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "emr_ec2_instance_profile" {
  name               = "${var.cluster_name}JobFlowInstanceProfile"
  path               = "/emr/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
resource "aws_iam_role_policy_attachment" "emr_ec2_instance_profile" {
  role       = aws_iam_role.emr_ec2_instance_profile.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2" {
  name = aws_iam_role.emr_ec2_instance_profile.name
  role = aws_iam_role.emr_ec2_instance_profile.name
}

resource "aws_iam_role" "ec2_autoscaling" {
  name               = "${var.cluster_name}-autoscaling"
  path               = "/emr/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_role_policy_attachment" "ec2_autoscaling" {
  role       = aws_iam_role.ec2_autoscaling.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}

# ---------------------------------------------------------------------------------------------------------------------
#  EMR CLUSTER DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_emr_cluster" "emr_cluster" {
  name          = var.cluster_name
  release_label = var.release_label

  # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-sg-specify.html
  ec2_attributes {
    key_name                          = var.key_name
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = aws_security_group.managed_master.id
    emr_managed_slave_security_group  = aws_security_group.managed_slave.id
    additional_master_security_groups = aws_security_group.master.id
    additional_slave_security_groups  = aws_security_group.slave.id
    service_access_security_group     = var.subnet_type == "private" ? join("", aws_security_group.managed_service_access.*.id) : null
    instance_profile                  = aws_iam_instance_profile.ec2.arn
  }

  termination_protection            = var.termination_protection
  keep_job_flow_alive_when_no_steps = var.keep_job_flow_alive_when_no_steps
  ebs_root_volume_size              = var.ebs_root_volume_size
  custom_ami_id                     = var.custom_ami_id
  visible_to_all_users              = var.visible_to_all_users

  applications = var.applications

  configurations_json = var.configurations_json

  core_instance_group {
    name           = var.cluster_name
    instance_type  = var.core_instance_group_instance_type
    instance_count = var.core_instance_group_instance_count

    ebs_config {
      size                 = var.core_instance_group_ebs_size
      type                 = var.core_instance_group_ebs_type
      iops                 = var.core_instance_group_ebs_iops
      volumes_per_instance = var.core_instance_group_ebs_volumes_per_instance
    }

    bid_price          = var.core_instance_group_bid_price
    autoscaling_policy = var.core_instance_group_autoscaling_policy
  }

  master_instance_group {
    name           = var.cluster_name
    instance_type  = var.master_instance_group_instance_type
    instance_count = var.master_instance_group_instance_count
    bid_price      = var.master_instance_group_bid_price

    ebs_config {
      size                 = var.master_instance_group_ebs_size
      type                 = var.master_instance_group_ebs_type
      iops                 = var.master_instance_group_ebs_iops
      volumes_per_instance = var.master_instance_group_ebs_volumes_per_instance
    }
  }

  scale_down_behavior    = var.scale_down_behavior
  additional_info        = var.additional_info
  security_configuration = var.security_configuration

  dynamic "bootstrap_action" {
    for_each = var.bootstrap_action
    content {
      path = bootstrap_action.value.path
      name = bootstrap_action.value.name
      args = bootstrap_action.value.args
    }
  }

  log_uri = var.s3_log_uri

  service_role     = aws_iam_role.emr_service_role.arn
  autoscaling_role = aws_iam_role.ec2_autoscaling.arn

  tags = var.custom_tags

  lifecycle {
    ignore_changes = ["kerberos_attributes", "step"]
  }
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html
# https://www.terraform.io/docs/providers/aws/r/emr_instance_group.html
resource "aws_emr_instance_group" "task" {
  count      = var.create_task_instance_group ? 1 : 0
  name       = var.cluster_name
  cluster_id = aws_emr_cluster.emr_cluster.id

  instance_type  = var.task_instance_group_instance_type
  instance_count = var.task_instance_group_instance_count

  ebs_config {
    size                 = var.task_instance_group_ebs_size
    type                 = var.task_instance_group_ebs_type
    iops                 = var.task_instance_group_ebs_iops
    volumes_per_instance = var.task_instance_group_ebs_volumes_per_instance
  }

  bid_price          = var.task_instance_group_bid_price
  ebs_optimized      = var.task_instance_group_ebs_optimized
  autoscaling_policy = var.task_instance_group_autoscaling_policy
}
