variable "rds_cluster_password" {
    default = "xxx"
}

variable "rds_cluster_instance_class" {
    default = "db.r4.large"
}

variable "rds_cluster_publicly_accessible" {
    default = true
}

variable "rds_cluster_backup_window" {
    default = "19:00-19:30"
}

variable "rds_cluster_maintenance_window" {
    default = "Sun:20:00-Sun:20:30"
}

variable "rds_cluster_parameter_family" {
    default = "aurora5.6"
}

resource "aws_db_parameter_group" "default" {
  name        = "${var.environment}"
  family      = "${var.rds_cluster_parameter_family}"
  description = "${var.environment} parameter group"

  parameter {
      name         = "innodb_file_format"
      value        = "Barracuda"
      apply_method = "pending-reboot"
  }
  parameter {
      name         = "innodb_large_prefix"
      value        = 1
      apply_method = "pending-reboot"
  }
}

resource "aws_rds_cluster_parameter_group" "default" {
  name        = "${var.environment}-cluster"
  family      = "${var.rds_cluster_parameter_family}"
  description = "${var.environment} cluster parameter group"

  parameter {
    name         = "character_set_client"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_connection"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_database"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_filesystem"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_results"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_server"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_connection"
    value        = "utf8mb4_general_ci"
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_server"
    value        = "utf8mb4_general_ci"
    apply_method = "immediate"
  }

  parameter {
    name         = "time_zone"
    value        = "Asia/Tokyo"
    apply_method = "immediate"
  }
}

resource "aws_rds_cluster" "default" {
    cluster_identifier              = "${var.environment}"
    availability_zones              = [
      "${var.aws_default_region}a",
      "${var.aws_default_region}c",
      "${var.aws_default_region}d"
    ]
    database_name                   = "gkquest"
    master_username                 = "gkquest"
    master_password                 = "${var.rds_cluster_password}"
    vpc_security_group_ids          = ["${aws_security_group.default.id}"]
    db_subnet_group_name            = "${aws_db_subnet_group.default.id}"
    db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.default.name}"
    preferred_backup_window         = "${var.rds_cluster_backup_window}"
    preferred_maintenance_window    = "${var.rds_cluster_maintenance_window}"
    apply_immediately               = true
}

resource "aws_db_subnet_group" "default" {
    name        = "${var.environment}"
    description = "${var.environment} subnet group"
    subnet_ids  = ["${aws_subnet.default-a.id}", "${aws_subnet.default-c.id}", "${aws_subnet.default-d.id}"]
}

resource "aws_rds_cluster_instance" "writer" {
  identifier              = "${var.environment}-writer"
  cluster_identifier      = "${aws_rds_cluster.default.id}"
  instance_class          = "${var.rds_cluster_instance_class}"
  db_parameter_group_name = "${aws_db_parameter_group.default.name}"
  db_subnet_group_name    = "${aws_db_subnet_group.default.id}"
  publicly_accessible     = "${var.rds_cluster_publicly_accessible}"
}

resource "aws_rds_cluster_instance" "reader" {
  count                   = 1
  identifier              = "${var.environment}-reader-${count.index+1}"
  cluster_identifier      = "${aws_rds_cluster.default.id}"
  instance_class          = "${var.rds_cluster_instance_class}"
  db_parameter_group_name = "${aws_db_parameter_group.default.name}"
  db_subnet_group_name    = "${aws_db_subnet_group.default.id}"
  publicly_accessible     = "${var.rds_cluster_publicly_accessible}"
}
