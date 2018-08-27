resource "aws_cloudwatch_dashboard" "default" {
  dashboard_name = "${var.environment}"
  dashboard_body = <<EOF
  {
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              "${aws_autoscaling_group.default.name}"
            ]
          ],
          "region": "${var.aws_default_region}",
          "period": 300,
          "title": "AutoScaling CPU使用率"
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 0,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "TargetGroup",
              "${aws_alb_target_group.app.arn_suffix}",
              "LoadBalancer",
              "${aws_alb.default.arn_suffix}"
            ]
          ],
          "region": "${var.aws_default_region}",
          "period": 300,
          "title": "EC2 有効インスタンス数"
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 6,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              "${aws_alb.default.arn_suffix}",
              {
                "stat": "Sum",
                "period": 60
              }
            ]
          ],
          "region": "${var.aws_default_region}",
          "title": "ALB リクエスト数",
          "period": 300
        }
      },

      {
        "type": "metric",
        "x": 12,
        "y": 6,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              "${aws_alb.default.arn_suffix}"
            ]
          ],
          "region": "${var.aws_default_region}",
          "period": 300,
          "title": "ALB 5xx カウント"
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 12,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/RDS",
              "CPUUtilization",
              "Role",
              "WRITER",
              "DBClusterIdentifier",
              "${aws_rds_cluster.default.id}"
            ],
            [
              "...",
              "READER",
              ".",
              "."
            ]
          ],
          "region": "${var.aws_default_region}",
          "period": 300,
          "title": "RDS CPU使用率"
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 12,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/RDS",
              "FreeableMemory",
              "Role",
              "WRITER",
              "DBClusterIdentifier",
              "${aws_rds_cluster.default.id}"
            ],
            [
              "...",
              "READER",
              ".",
              "."
            ]
          ],
          "region": "${var.aws_default_region}",
          "title": "RDS 空きメモリ容量"
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 18,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/RDS",
              "DatabaseConnections",
              "Role",
              "READER",
              "DBClusterIdentifier",
              "${aws_rds_cluster.default.id}",
              {
                "stat": "Sum",
                "period": 60
              }
            ],
            [
              "...",
              "WRITER",
              ".",
              ".",
              {
                "stat": "Sum",
                "period": 60
              }
            ]
          ],
          "region": "${var.aws_default_region}",
          "title": "RDS 接続数"
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 18,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/ElastiCache",
              "CPUUtilization",
              "CacheClusterId",
              "${aws_elasticache_cluster.default.cluster_id}"
            ]
          ],
          "region": "${var.aws_default_region}",
          "title": "ElastiCache CPU使用率"
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 24,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/ElastiCache",
              "FreeableMemory",
              "CacheClusterId",
              "${aws_elasticache_cluster.default.cluster_id}"
            ]
          ],
          "region": "${var.aws_default_region}",
          "title": "ElastiCache 空きメモリ容量"
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 24,
        "width": 12,
        "height": 6,
        "styles": "undefined",
        "properties": {
          "view": "timeSeries",
          "stacked": false,
          "metrics": [
            [
              "AWS/ElastiCache",
              "CurrConnections",
              "CacheClusterId",
              "${aws_elasticache_cluster.default.cluster_id}"
            ]
          ],
          "region": "${var.aws_default_region}",
          "title": "ElastiCache 接続数 "
        }
      }
    ]
  }
EOF
}
