resource "google_monitoring_alert_policy" "cpu_usage" {
  display_name = "CPU-Utilization-GCE"
  severity     = "CRITICAL"
  combiner     = "AND"
  alert_strategy {
    auto_close = "86400s" # Close the alert after 1 day.
  }
  conditions {
    display_name = "Metric Threshold on All Instance (GCE)s"
    condition_threshold {
      filter     = <<EOT
              metric.type="compute.googleapis.com/instance/cpu/utilization" AND
              resource.type="gce_instance"
      EOT
      duration   = "180s" # Condition needs to be breached for over than 3 minutes
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["project", "metadata.system_labels.name", "resource.label.zone", "resource.label.instance_id"]
      }
      threshold_value = 0.95
      trigger {
        count = 1
      }
    }
  }
  documentation {
    mime_type = "text/markdown"
    content   = "Verify which process is cause CPU spike."
  }
  notification_channels = [google_monitoring_notification_channel.on_call_team.name]
}

resource "google_monitoring_alert_policy" "memory_usage" {
  display_name = "Memory-Utilization-GCE"
  severity     = "CRITICAL"
  combiner     = "AND"
  alert_strategy {
    auto_close = "86400s" # Close the alert after 1 day.
  }
  conditions {
    display_name = "Metric Threshold on All Instance (GCE)s"
    condition_threshold {
      filter     = <<EOT
              metric.label.state="used" AND
              metric.type="agent.googleapis.com/memory/percent_used" AND
              resource.type="gce_instance"
      EOT
      duration   = "180s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["project", "metadata.system_labels.name", "resource.label.instance_id", "resource.label.zone"]
      }
      threshold_value = 95
      trigger {
        count = 1
      }
    }
  }
  documentation {
    mime_type = "text/markdown"
    content   = "Verify which process is cause Memory spike."
  }
  notification_channels = [google_monitoring_notification_channel.on_call_team.name]
}

resource "google_monitoring_alert_policy" "uptime_check" {
  display_name = "Uptime-Check"
  severity     = "CRITICAL"
  combiner     = "OR"
  alert_strategy {
    auto_close = "86400s" # Close the alert after 1 day.
  }
  conditions {
    display_name = "Uptime check for GCE INSTANCE - Platform"
    condition_threshold {
      evaluation_missing_data = "EVALUATION_MISSING_DATA_ACTIVE"
      filter                  = <<EOT
              metric.type="compute.googleapis.com/instance/uptime" AND
              resource.type="gce_instance"
      EOT
      duration                = "300s"
      comparison              = "COMPARISON_LT"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["project", "metadata.system_labels.name", "resource.label.zone", "resource.label.instance_id"]
      }
      threshold_value = 1
      trigger {
        count = 1
      }
    }
  }
  documentation {
    mime_type = "text/markdown"
    content   = "Verify if instance is running, find the cause of the alert."
  }
  notification_channels = [google_monitoring_notification_channel.on_call_team.name]
}

resource "google_monitoring_alert_policy" "disk_usage" {
  display_name = "Disk-Utilization-GCE"
  severity     = "CRITICAL"
  combiner     = "AND_WITH_MATCHING_RESOURCE"
  alert_strategy {
    auto_close = "86400s" # Close the alert after 1 day.
  }
  conditions {
    display_name = "Metric Threshold on All Instance (GCE)s"
    condition_threshold {
      filter     = <<EOT
              metric.type="agent.googleapis.com/disk/percent_used" AND
              resource.type="gce_instance" AND
              metric.label.device!=monitoring.regex.full_match(".*(loop[0-9]|tmpfs|udev|sda15).*") AND
              metric.label.state="used"

      EOT
      duration   = "60s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["project", "metadata.system_labels.name", "metric.label.device", "resource.label.zone", "resource.labels.instance_id"]
      }
      threshold_value = 90
      trigger {
        count = 1
      }
    }
  }
  documentation {
    mime_type = "text/markdown"
    content   = "Find large files and verify if space expansion is required."
  }

  notification_channels = [google_monitoring_notification_channel.on_call_team.name]
}
