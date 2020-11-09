name 'chef-linux-base-recipe'
maintainer 'HashiCorp'
maintainer_email 'hello@hashicorp.com'
license 'Apache-2.0'
description 'Installs/Configures chef-linux-base-recipe'
version '0.1.1'
chef_version '>= 14.0'

issues_url 'https://github.com/mtharpe/chef-linux-base-recipe/issues'
source_url 'https://github.com/mtharpe/chef-linux-base-recipe'

supports 'redhat'
supports 'ubuntu'
supports 'debian'

depends 'yum-epel', '~> 3.3.0'
depends 'vim', '~> 2.1.0'
depends 'os-hardening', '~> 4.0.0'
depends 'ssh-hardening', '~> 2.9.0'
