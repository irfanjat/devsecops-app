package main

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not startswith(container.image, "ghcr.io/")
  msg = sprintf("Container '%s' must use images from trusted registry (ghcr.io)", [container.name])
}

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  endswith(container.image, ":latest")
  msg = sprintf("Container '%s' must not use 'latest' tag", [container.name])
}
