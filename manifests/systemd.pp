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

  $facts['networking']['interfaces'].each |String $iface, Any $value| {
    if $iface != 'lo' {
      file { "/etc/systemd/network/${iface}.network":
        ensure   => file,
        contents => template('network/interface.network.erb'),
        notify   => Service['systemd-networkd'],
      }
    }
  }
  service { 'systemd-networkd':
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
    ensure => absent,
    notify => Service['systemd-networkd'],
  }
}
