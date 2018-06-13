# Puppet class that controls the Kubelet service
class kubernetes::service (
  String $etcd_ip     = $kubernetes::etcd_ip,
  Boolean $controller = $kubernetes::controller,
) {
    service { 'docker':
      ensure => running,
      enable => true,
    }

  if $controller {
    service { 'etcd':
      ensure  => running,
      enable  => true,
      require => File['/etc/systemd/system/etcd.service']
    }

  }
}
