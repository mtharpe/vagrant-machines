#
# Cookbook:: ssh-hardening
# Attributes:: default
#
# Copyright:: 2012, Dominik Richter
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Define the client package name
case node['platform']
when 'redhat', 'centos', 'fedora', 'amazon', 'oracle', 'scientific'
  default['ssh-hardening']['sshclient']['package'] = 'openssh-clients'
when 'debian', 'ubuntu'
  default['ssh-hardening']['sshclient']['package'] = 'openssh-client'
when 'arch', 'suse', 'opensuse', 'opensuseleap'
  default['ssh-hardening']['sshclient']['package'] = 'openssh'
else
  default['ssh-hardening']['sshclient']['package'] = 'openssh-client'
end

# Define the package name for selinux utils

if platform_family?('fedora') || # rubocop:disable Style/ConditionalAssignment
   platform_family?('rhel') && node['platform_version'].to_f >= 8
  default['ssh-hardening']['selinux']['package'] = 'policycoreutils-python-utils'
else
  default['ssh-hardening']['selinux']['package'] = 'policycoreutils-python'
end

# Define the server package name
default['ssh-hardening']['sshserver']['package'] = if platform?('suse', 'opensuse', 'opensuseleap')
                                                     'openssh'
                                                   else
                                                     'openssh-server'
                                                   end

# Define the service name for sshd
default['ssh-hardening']['sshserver']['service_name'] = if platform_family?('rhel', 'fedora', 'suse', 'freebsd', 'gentoo', 'amazon')
                                                          'sshd'
                                                        else
                                                          'ssh'
                                                        end

# sshd + ssh client
default['ssh-hardening']['network']['ipv6']['enable']      = false
default['ssh-hardening']['config_disclaimer']              = '**Note:** This file was automatically created by Hardening Framework (dev-sec.io) configuration. If you use its automated setup, do not edit this file directly, but adjust the automation instead.'
default['ssh-hardening']['ssh']['ports']                   = [22]

# ssh client
default['ssh-hardening']['ssh']['client'].tap do |client|
  client['mac']           = nil     # nil = calculate best combination for client
  client['kex']           = nil     # nil = calculate best combination for client
  client['cipher']        = nil     # nil = calculate best combination for client
  client['cbc_required']  = false
  client['weak_hmac']     = false
  client['weak_kex']      = false
  client['allow_agent_forwarding'] = false
  client['remote_hosts'] = []
  client['password_authentication'] = false # ssh

  # http://undeadly.org/cgi?action=article&sid=20160114142733
  client['roaming']       = false
  client['send_env']      = ['LANG', 'LC_*', 'LANGUAGE']

  # extra client configuration options
  client['extras']        = {}
end

# sshd
default['ssh-hardening']['ssh']['server'].tap do |server| # rubocop: disable Metrics/BlockLength
  server['kex']                      = nil     # nil = calculate best combination for server version
  server['cipher']                   = nil     # nil = calculate best combination for server version
  server['mac']                      = nil     # nil = calculate best combination for server version
  server['cbc_required']             = false
  server['weak_hmac']                = false
  server['weak_kex']                 = false
  server['dh_min_prime_size']        = 2048
  server['dh_build_primes']          = false
  server['dh_build_primes_size']     = 4096
  server['host_key_files']           = nil
  server['client_alive_interval']    = 300     # 5min
  server['client_alive_count']       = 3       # ~> 3 x interval
  server['allow_root_with_key']      = false
  server['permit_tunnel']            = false
  server['allow_tcp_forwarding']     = false
  server['allow_agent_forwarding']   = false
  server['allow_x11_forwarding']     = false
  server['use_pam']                  = true
  server['challenge_response_authentication'] = false
  server['deny_users']               = []
  server['allow_users']              = []
  server['deny_groups']              = []
  server['allow_groups']             = []
  server['print_motd']               = false
  server['print_last_log']           = false
  server['banner']                   = nil     # set this to nil to disable banner or provide a path like '/etc/issue.net'
  server['os_banner']                = false   # (Debian OS family)
  server['use_dns']                  = nil     # set this to nil to let us use the default OpenSSH in case it's not set by the user
  server['use_privilege_separation'] = nil     # set this to nil to let us detect the attribute based on the node platform
  server['login_grace_time']         = '30s'
  server['max_auth_tries']           = 2
  server['max_sessions']             = 10
  server['password_authentication']  = false
  server['log_level']                = 'verbose'
  server['accept_env']               = ['LANG', 'LC_*', 'LANGUAGE']
  server['authorized_keys_path']     = nil     # if not nil, full path to one or multipe space-separated authorized keys file is expected

  # extra server configuration options
  server['extras']                   = {}

  # server match configuration block
  server['match_blocks']             = {}

  # sshd sftp options
  server['sftp']['enable']                  = false
  server['sftp']['log_level']               = 'VERBOSE'
  server['sftp']['group']                   = 'sftponly'
  server['sftp']['chroot']                  = '/home/%u'
  server['sftp']['authorized_keys_path']    = nil     # if not nil, full path to one or multipe space-separated authorized keys file is expected
  server['sftp']['password_authentication'] = false
end
