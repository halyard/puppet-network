# == Class: network
#
# Configure network settings
#
class network (
) {
  sysctl::entry { 'net.inet6.ip6.use_tempaddr':
    value => '0',
  }
}
