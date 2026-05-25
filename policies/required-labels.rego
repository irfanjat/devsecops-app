package main

deny[msg] {
  input.kind == "Deployment"
  not input.metadata.labels.app
  msg = "Deployment must have an 'app' label"
}

deny[msg] {
  input.kind == "Deployment"
  not input.spec.template.metadata.labels.app
  msg = "Pod template must have an 'app' label"
}
