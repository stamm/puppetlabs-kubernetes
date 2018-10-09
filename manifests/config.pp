#Calss kubernetes config, populates config files with params to bootstrap cluster
class kubernetes::config (

  String $kubernetes_version  = $kubernetes::kubernetes_version,
  String $etcd_ca_key = $kubernetes::etcd_ca_key,
  String $etcd_ca_crt = $kubernetes::etcd_ca_crt,
  String $etcdclient_key = $kubernetes::etcdclient_key,
  String $etcdclient_crt = $kubernetes::etcdclient_crt,
  String $etcdserver_crt = $kubernetes::etcdserver_crt,
  String $etcdserver_key = $kubernetes::etcdserver_key,
  String $etcdpeer_crt = $kubernetes::etcdpeer_crt,
  String $etcdpeer_key = $kubernetes::etcdpeer_key,
  Array $etcd_peers = $kubernetes::etcd_peers,
  String $etcd_ip = $kubernetes::etcd_ip,
  String $cni_pod_cidr = $kubernetes::cni_pod_cidr,
  Optional[Boolean] $cni_pod_cidr_allocate = $kubernetes::cni_pod_cidr_allocate,
  Optional[Integer[1, 32]] $cni_pod_cidr_mask = $kubernetes::cni_pod_cidr_mask,
  Stdlib::Ip_address $controller_manager_address = $kubernetes::controller_manager_address,
  Stdlib::Ip_address $scheduler_address = $kubernetes::scheduler_address,
  String $kube_api_advertise_address = $kubernetes::kube_api_advertise_address,
  String $etcd_initial_cluster = $kubernetes::etcd_initial_cluster,
  Integer $api_server_count = $kubernetes::api_server_count,
  String $etcd_version = $kubernetes::etcd_version,
  String $token = $kubernetes::token,
  String $token_ttl = $kubernetes::token_ttl,
  String $discovery_token_hash = $kubernetes::discovery_token_hash,
  String $kubernetes_ca_crt = $kubernetes::kubernetes_ca_crt,
  String $kubernetes_ca_key = $kubernetes::kubernetes_ca_key,
  String $kubernetes_front_proxy_ca_crt = $kubernetes::kubernetes_front_proxy_ca_crt,
  String $kubernetes_front_proxy_ca_key = $kubernetes::kubernetes_front_proxy_ca_key,
  String $container_runtime = $kubernetes::container_runtime,
  String $sa_pub = $kubernetes::sa_pub,
  String $sa_key = $kubernetes::sa_key,
  Optional[Array] $apiserver_cert_extra_sans = $kubernetes::apiserver_cert_extra_sans,
  Optional[Array] $apiserver_extra_arguments = $kubernetes::apiserver_extra_arguments,
  String $service_cidr = $kubernetes::service_cidr,
  String $node_label = $kubernetes::node_label,
  Optional[String] $cloud_provider = $kubernetes::cloud_provider,
  Optional[Hash[String, Boolean]] $feature_gates = $kubernetes::feature_gates,

) {

  $kube_dirs = ['/etc/kubernetes','/etc/kubernetes/manifests','/etc/kubernetes/pki','/etc/kubernetes/pki/etcd']
  $etcd = ['ca.crt', 'ca.key', 'client.crt', 'client.key','peer.crt', 'peer.key', 'server.crt', 'server.key']
  $pki = ['ca.crt', 'ca.key', 'front-proxy-ca.crt', 'front-proxy-ca.key', 'sa.pub','sa.key']
  $kube_dirs.each | String $dir |  {
    file  { $dir :
      ensure => directory,

    }
  }

  $etcd.each | String $etcd_files | {
    file { "/etc/kubernetes/pki/etcd/${etcd_files}":
      ensure  => present,
      mode    => '0644',
      content => template("kubernetes/etcd/${etcd_files}.erb"),
    }
  }

  $pki.each | String $pki_files | {
    file {"/etc/kubernetes/pki/${pki_files}":
      ensure  => present,
      mode    => '0644',
      content => template("kubernetes/pki/${pki_files}.erb"),
    }
  }

  file { '/etc/systemd/system/etcd.service':
    ensure  => present,
    content => template('kubernetes/etcd/etcd.service.erb'),
  }

  file { '/etc/kubernetes/config.yaml':
    ensure  => present,
    content => template('kubernetes/config.yaml.erb'),
  }

}
