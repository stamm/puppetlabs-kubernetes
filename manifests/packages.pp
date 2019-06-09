# Class kubernetes packages

class kubernetes::packages (

  String $kubernetes_version                   = $kubernetes::kubernetes_version,
  String $container_runtime                    = $kubernetes::container_runtime,
  Optional[String] $docker_version             = $kubernetes::docker_version,
  String $etcd_version                         = $kubernetes::etcd_version,
  Optional[String] $containerd_version         = $kubernetes::containerd_version,
  Boolean $controller                          = $kubernetes::controller,

) {

  $kube_packages = ['kubelet', 'kubectl', 'kubeadm']
  $containerd_archive = "containerd-${containerd_version}.linux-amd64.tar.gz"
  $containerd_source = "https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}"
  $etcd_archive = "etcd-v${etcd_version}-linux-amd64.tar.gz"
  $etcd_source = "https://github.com/coreos/etcd/releases/download/v${etcd_version}/${etcd_archive}"

  if $::osfamily == 'RedHat' {
    exec { 'set up bridge-nf-call-iptables':
      path    => ['/usr/sbin/', '/usr/bin', '/bin'],
      command => 'modprobe br_netfilter',
      creates => '/proc/sys/net/bridge/bridge-nf-call-iptables',
      before  => File_line['set 1 /proc/sys/net/bridge/bridge-nf-call-iptables'],
    }

    file_line { 'set 1 /proc/sys/net/bridge/bridge-nf-call-iptables':
      path    => '/proc/sys/net/bridge/bridge-nf-call-iptables',
      replace => true,
      line    => '1',
      match   => '0',
      require => Exec['set up bridge-nf-call-iptables'],
    }
  }


  case $container_runtime {
    'docker': {
      case $::osfamily {
        'Debian': {
          case $::lsbdistcodename {
            'bionic': {
              $docker_package_name = 'docker.io'
            }
            default: {
              $docker_package_name = 'docker-engine'
            }
          }
          package { $docker_package_name:
            ensure => $docker_version,
          }
        }
      default: { notify {"The OS family ${::osfamily} is not supported by this module":} }
      }
    }
    'docker-ce': {
      $docker_package_name = 'docker-ce'

      apt::source { 'docker-ce':
        architecture  => 'amd64',
        location      => 'https://download.docker.com/linux/ubuntu',
        repos         => 'stable',
        release       => $::lsbdistcodename,
        key           => {
          id     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
          source => 'https://download.docker.com/linux/ubuntu/gpg',
        }
      } ->
      package { 'docker.io':
        ensure => 'absent',
      } ->
      package { $docker_package_name:
        ensure => $docker_version,
      }
    }
  }

  if $controller {
    archive { $etcd_archive:
      path            => "/${etcd_archive}",
      source          => $etcd_source,
      extract         => true,
      extract_command => 'tar xfz %s --strip-components=1 -C /usr/local/bin/',
      extract_path    => '/usr/local/bin',
      cleanup         => true,
      creates         => ['/usr/local/bin/etcd','/usr/local/bin/etcdctl']
    }
  }

  package { $kube_packages:
    ensure => $kubernetes_version,
  }

}
