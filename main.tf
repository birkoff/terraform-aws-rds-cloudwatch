resource "aws_iam_role" "cloudwatch-logs-role" {
  name = "${format("%s-cw-logs-role", var.identifier)}"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudwatchOnRds",
      "Effect": "Allow",
      "Principal": {
        "Service": "monitoring.rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch-logs-policy" {
  name = "${format("%s-cw-logs-policy", var.identifier)}"
  role = "${aws_iam_role.cloudwatch-logs-role.id}"

  policy = <<EOP
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EnableCreationAndManagementOfRDSCloudwatchLogGroups",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:PutRetentionPolicy"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:RDS*"
            ]
        },
        {
            "Sid": "EnableCreationAndManagementOfRDSCloudwatchLogStreams",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:RDS*:log-stream:*"
            ]
        }
    ]
}
EOP
}


resource "aws_cloudwatch_metric_alarm" "db-cpu-utilization-alarm" {
  alarm_name                = "db-cpu-utilization-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "75"
  alarm_description         = "CPU utilization"
  alarm_actions             = "${var.alarm_actions}"
  ok_actions                = "${var.ok_actions}"
  insufficient_data_actions = "${var.insufficient_data_actions}"

  dimensions = {
    DBInstanceIdentifier = "${aws_db_instance.db.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "db-queue-depth-alarm" {
  alarm_name                = "db-queue-depth-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "DiskQueueDepth"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "DiskQueueDepthCount"
  alarm_actions             = "${var.alarm_actions}"
  ok_actions                = "${var.ok_actions}"
  insufficient_data_actions = "${var.insufficient_data_actions}"

  dimensions = {
    DBInstanceIdentifier = "${aws_db_instance.db.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "db-free-space-alarm" {
  alarm_name                = "db-free-space-alarm"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "2000"
  alarm_description         = "FreeStorageSpace"
  alarm_actions             = "${var.alarm_actions}"
  ok_actions                = "${var.ok_actions}"
  insufficient_data_actions = "${var.insufficient_data_actions}"

  dimensions = {
    DBInstanceIdentifier = "${aws_db_instance.db.id}"
  }
}
