package main

deny contains msg if {
  input.kind == "Deployment"
  not input.metadata.labels.app
  msg := "Deployment must have an 'app' label"
}

deny contains msg if {
  input.kind == "Deployment"
  not input.spec.template.metadata.labels.app
  msg := "Pod template must have an 'app' label"
}
