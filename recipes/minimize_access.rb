# encoding: utf-8
#
# Cookbook Name: nginx-hardening
# Recipe: minimize_access
#
# Copyright 2014, Deutsche Telekom AG
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

# change all the already created resource so we do not flap on o-rw
run_context.resource_collection.each do |resource|
  resource.mode('0600') if resource.name =~ /#{node['nginx']['dir']}/ && resource.mode == '0644'
  resource.mode('0750') if resource.name =~ /#{node['nginx']['dir']}/ && resource.mode == '0755'
  resource.mode('0600') if resource.name == 'nginx.conf'
end

# change all the other files not defined as resources
execute 'remove world readable files' do
  command "chmod -R o-rw #{node['nginx']['dir']}"
  not_if "find #{node['nginx']['dir']} -perm -o+r -type f -o -perm -o+w -type f | wc -l | egrep '^0$'"
end

directory '/usr/sbin/nginx' do
  owner node['system_admin']
  group node['system_admin']
  mode '550'
end

directory '/etc/nginx/' do
  owner node['system_admin']
  group node['system_admin']
  mode '770'
end

directory '/etc/nginx/conf.d' do
  owner node['system_admin']
  group node['system_admin']
  mode '770'
end

directory '/etc/nginx/modules' do
  owner node['system_admin']
  group node['system_admin']
  mode '770'
end
directory '/usr/share/nginx/html' do
  owner node['nginx_owner']
  group node['nginx_owner']
  mode '1775'
end
directory '/var/log/nginx' do
  owner  node['system_admin']
  group  node['system_admin']
  mode '750'
end

directory '/var/local' do
  owner  node['nginx_owner']
  group  node['nginx_owner']
  mode '1660'
end

directory '/var/www' do
  owner  node['nginx_owner']
  group  node['nginx_owner']
  mode '1755'
end

node['nginx_files'].each do |nginx_file|
  file nginx_file do
    owner  node['nginx_owner']
    group  node['nginx_owner']
    mode '0660'
  end
end