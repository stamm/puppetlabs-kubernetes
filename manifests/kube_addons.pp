# Class kubernetes kube_addons
class kubernetes::kube_addons (
  Boolean $install_dashboard  = $kubernetes::install_dashboard,
) {

  Exec {
    path        => ['/usr/bin', '/bin'],
    environment => [ 'HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
    logoutput   => true,
    tries       => 10,
    try_sleep   => 30,
    }

  if $install_dashboard  {
    exec { 'Install Kubernetes dashboard':
      command => 'kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml',
      onlyif  => 'kubectl get nodes',
      unless  => 'kubectl -n kube-system get pods | grep kubernetes-dashboard',
      }
    }
}
