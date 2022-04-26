##
# Definitions for Archlinux
class network::systemd {
  $resolvers = $network::resolvers
  $domains = $network::domains
  $dnsovertls = $network::dnsovertls
  $bridges = $network::bridges

  file { '/etc/systemd/resolved.conf':
    ensure  => file,
    content => template('network/resolved.conf.erb'),
  }
  ~> service { 'systemd-resolved':
    ensure => running,
    enable => true,
  }

  $bridges.each |String $bridge, String $child| {
    file { "/etc/systemd/network/${bridge}.network":
      ensure  => file,
      content => template('network/bridge.network.erb'),
      notify  => Service['systemd-networkd'],
    }

    file { "/etc/systemd/network/${bridge}.netdev":
      ensure  => file,
      content => template('network/bridge.netdev.erb'),
      notify  => Service['systemd-networkd'],
    }

    file { "/etc/systemd/network/${child}.network":
      ensure  => file,
      content => template('network/child.network.erb'),
      notify  => Service['systemd-networkd'],
    }
  }

  $bridge_children = values($bridges)

  $facts['networking']['interfaces'].each |String $iface, Any $value| {
    unless $iface == 'lo' or $iface in $bridge_children {
      file { "/etc/systemd/network/${iface}.network":
        ensure  => file,
        content => template('network/interface.network.erb'),
        notify  => Service['systemd-networkd'],
      }
    }
  }
  service { 'systemd-networkd':
    ensure => running,
    enable => true,
  }

  file { '/etc/systemd/network':
    ensure  => directory,
    recurse => true,
    purge   => true,
    notify  => Service['systemd-networkd'],
  }
}
