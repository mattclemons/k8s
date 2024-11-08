output "jenkins_url" {
  value       = "Jenkins service deployed. Retrieve IP manually via kubectl or DigitalOcean UI."
  description = "URL for Jenkins service."
}

output "sonarqube_url" {
  value       = "SonarQube service deployed. Retrieve IP manually via kubectl or DigitalOcean UI."
  description = "URL for SonarQube service."
}
