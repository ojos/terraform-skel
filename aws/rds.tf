variable "rds_storage" {
    default = 10
}

variable "rds_engine" {
    default = "mysql"
}

variable "rds_engine_version" {
    default = "5.6.37"
}

variable "rds_type" {
    default = "db.t2.small"
}

variable "rds_password" {
    default = "xxx"
}

variable "rds_multi_az" {
    default = false
}

variable "rds_publicly_accessible" {
    default = true
}

variable "rds_storage_type" {
    default = "standard"
}

variable "rds_backup_window" {
    default = "19:00-19:30"
}

variable "rds_maintenance_window" {
    default = "Sun:20:00-Sun:20:30"
}

variable "rds_parameter_family" {
    default = "mysql5.6"
}


resource "aws_db_instance" "default" {
    identifier             = "${var.environment}"
    allocated_storage      = "${var.rds_storage}"
    engine                 = "${var.rds_engine}"
    engine_version         = "${var.rds_engine_version}"
    instance_class         = "${var.rds_type}"
    storage_type           = "${var.rds_storage_type}"
    name                   = "gkquest"
    username               = "gkquest"
    password               = "${var.rds_password}"
    availability_zone      = "${var.aws_default_region}c"
    multi_az               = "${var.rds_multi_az}"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
    parameter_group_name   = "${aws_db_parameter_group.default.id}"
    publicly_accessible    = "${var.rds_publicly_accessible}"
    backup_window          = "${var.rds_backup_window}"
    maintenance_window     = "${var.rds_maintenance_window}"
    apply_immediately      = true
}

resource "aws_db_subnet_group" "default" {
    name        = "${var.environment}"
    description = "${var.environment} subnet group"
    subnet_ids  = ["${aws_subnet.default-a.id}", "${aws_subnet.default-c.id}", "${aws_subnet.default-d.id}"]
}

resource "aws_db_parameter_group" "default" {
    name        = "${var.environment}"
    family      = "${var.rds_parameter_family}"
    description = "${var.environment} parameter group"

    parameter {
        name         = "init_connect"
        value        = "SET NAMES utf8mb4;"
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "character_set_client"
        value        = "utf8mb4"
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "character_set_connection"
        value        = "utf8mb4"
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "character_set_database"
        value        = "utf8mb4"
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "character_set_results"
        value        = "utf8mb4"
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "character_set_server"
        value        = "utf8mb4"
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "collation_server"
        value        = "utf8mb4_general_ci"
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "skip-character-set-client-handshake"
        value        = 1
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "innodb_file_format"
        value        = "Barracuda"
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "innodb_file_per_table"
        value        = 1
        apply_method = "pending-reboot"
    }
    parameter {
        name         = "innodb_large_prefix"
        value        = 1
        apply_method = "pending-reboot"
    }

    parameter {
      name           = "time_zone"
      value          = "Asia/Tokyo"
      apply_method   = "pending-reboot"
    }
}
