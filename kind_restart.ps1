# Common Variables
$imageName      = "kind_docker_image"
$containerName  = "kind_container"
$network_type   = "--network=host"
$socket_volume  = "/var/run/docker.sock:/var/run/docker.sock"
$playbook_exec  = "ansible-playbook -i ansible/inventory.ini ansible/playbook.yaml"
$argocd_install = "kubectl apply -n argocd-ns -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
$apply_app      = "kubectl apply -f application.yaml"
$kyverno_config = "kubectl apply -f kind-config/charts/dev/kyverno/deployment.yaml"

# Docker Variables
$KindDelCmd      = "docker exec -it $containerName sh -c 'kind delete cluster'"
$DockerStopCmd   = "docker stop $containerName"
$DockerRemoveCmd = "docker rm $containerName"
$DockerBuildCmd  = "docker build -t $imageName ."
$DockerRunCmd    = "docker run -d $network_type -v $socket_volume --name $containerName $imageName"

# Ansible Variables
$AnsiblePlaybook = "docker exec -it $containerName sh -c '$playbook_exec'"

# ArgoCD variables
$Apply_ArgoCD  = "docker exec -it $containerName sh -c '$argocd_install'"
$Apply_ArgoApp = "docker exec -it $containerName sh -c '$apply_app'"

# Kubernetes Environment Variables
$Apply_Kyverno = "docker exec -it $containerName sh -c '$kyverno_config'"

## RUN commands ##

# Execute Docker container to delete kind cluster
Invoke-Expression -Command $KindDelCmd
# Stop the Docker container
Invoke-Expression -Command $DockerStopCmd
# Remove the Docker container
Invoke-Expression -Command $DockerRemoveCmd

# Rebuild
Invoke-Expression -Command $DockerBuildCmd
Invoke-Expression -Command $DockerRunCmd
Invoke-Expression -Command $AnsiblePlaybook
Start-Sleep -Seconds 10

# Argocd install and manifest application ##
Invoke-Expression -Command $Apply_ArgoCD
Invoke-Expression -Command $Apply_ArgoApp
Start-Sleep -Seconds 120

# Apply Kubernetes config
# Invoke-Expression -Command $Apply_Kyverno