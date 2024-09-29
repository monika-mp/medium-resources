resource "google_monitoring_notification_channel" "on_call_team" {
  display_name = "On call team"
  type         = "email"
  labels = {
    email_address = var.on_call_team
  }

}