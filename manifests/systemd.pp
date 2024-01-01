##
# Definitions for Archlinux
class network::systemd {
  $resolvers = $network::resolvers
  $domains = $network::domains
  $dnsovertls = $network::dnsovertls
  $bridges = $network::bridges
  $vlans = $network::vlans
  $ignore = $network::ignore

  file { '/etc/resolv.conf':
    ensure => link,
    target => '/run/systemd/resolve/stub-resolv.conf',
  }

  file { '/etc/systemd/resolved.conf':
    ensure  => file,
    content => template('network/resolved.conf.erb'),
  }
  ~> service { 'systemd-resolved':
    ensure => running,
    enable => true,
  }

  $bridges.each |String $bridge, Array[String] $children| {
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

    $children.each |String $child| {
      $child_file_name = regsubst($child, '\*', '')
      file { "/etc/systemd/network/${child_file_name}.network":
        ensure  => file,
        content => template('network/child.network.erb'),
        notify  => Service['systemd-networkd'],
      }
    }
  }

  $bridge_children = values($bridges).flatten

  $vlans.each |String $vlan_name, Hash[String, String] $params| {
    file { "/etc/systemd/network/${vlan_name}.network":
      ensure  => file,
      content => template('network/vlan.network.erb'),
      notify  => Service['systemd-networkd'],
    }

    file { "/etc/systemd/network/${vlan_name}.netdev":
      ensure  => file,
      content => template('network/vlan.netdev.erb'),
      notify  => Service['systemd-networkd'],
    }
  }

  $real_interfaces = $facts['networking']['interfaces'].filter |String $iface, Any $value| {
    !($iface in $bridge_children or $iface in $bridges or $iface in $vlans or $ignore.any |$item| { $iface.match($item) })
  }

  $primary_interface = sort($real_interfaces)[0]

  $real_interfaces.each |String $iface, Any $value| {
    file { "/etc/systemd/network/${iface}.network":
      ensure  => file,
      content => template('network/interface.network.erb'),
      notify  => Service['systemd-networkd'],
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
