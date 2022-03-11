##
# Definitions for Archlinux
class network::systemd {
  $resolvers = $network::resolvers
  $domains = $network::domains
  $dnsovertls = $network::dnsovertls

  file { '/etc/systemd/resolved.conf':
    ensure  => file,
    content => template('network/resolved.conf.erb'),
  }
  ~> service { 'systemd-resolved':
    ensure => running,
    enable => true,
  }

  # Remove network overrides on Linodes
  $linode_files = [
    '/etc/systemd/network/05-eth0.network',
    '/etc/systemd/network/.05-eth0.network.linode-orig',
    '/etc/systemd/network/.05-eth0.network.linode-last',
  ]
  file { $linode_files:
    ensure  => absent,
  }
  ~> service { 'systemd-networkd':
    ensure => running,
    enable => true,
  }
}
