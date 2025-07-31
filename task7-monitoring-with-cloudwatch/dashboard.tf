# provides a cloudwatch dashboard resource

resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "ecs-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x = 0
        y = 0
        width = 24
        height = 6
        properties = {
          metrics = [
            # ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, { stat = "Average" }],
            # ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, { stat = "Average" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, "ServiceName", aws_ecs_service.ecs_service.name],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, "ServiceName", aws_ecs_service.ecs_service.name]

          ]
          annotations = {}
          period = 300
          region = var.region
          title = "ECS Cluster Metrics"
          view = "timeSeries"
          stacked = false
        }
      }
    ]
  })
}