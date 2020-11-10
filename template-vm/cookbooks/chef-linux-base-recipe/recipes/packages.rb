#
# Cookbook:: chef-linux-base-recipe
# Recipe:: packages
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

include_recipe 'yum-epel::default' if platform_family?('rhel')

if platform?('ubuntu')
  %w(apparmor landscape-client-ui landscape-client-ui-install landscape-client landscape-common ufw).each do |pkg|
    package pkg do
      action :purge
    end
  end
end

case node['os']
when 'linux'

  %w(bash curl wget unzip mlocate vim).each do |pkg|
    package pkg do
      action :install
    end
  end
end
