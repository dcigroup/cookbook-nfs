#
# Cookbook Name:: nfs
# Recipe:: undo 
#
# Copyright 2012, Eric G. Wolfe
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

# Stop nfs server components
service node['nfs']['service']['server'] do
  action [ :stop, :disable ]
end

service "nfslock" do
  case node['platform']
  when "ubuntu"
    if node["platform_version"].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  service_name node['nfs']['service']['lock']
  action [ :stop, :disable ]
end

# Stop nfs client components
service "portmap" do
  case node['platform']
  when "ubuntu"
    if node["platform_version"].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  service_name node['nfs']['service']['portmap']
  action [ :stop, :disable ]
end

# Remove package, dependent on platform
node['nfs']['packages'].each do |nfspkg|
  package nfspkg do
    action :remove
  end
end

# Remove server components for Debian
case node['platform_family']
when "debian"
  package "nfs-kernel-server" do
    action :remove
  end
end

if not Chef::Config[:solo] then
  ruby_block "remove nfs::undo from run_list when there is a conflict" do
    block do
      node.run_list.remove("recipe[nfs::undo]")
    end
    only_if { node.run_list.include?("recipe[nfs::default]") or node.run_list.include?("recipe[nfs::server]") }
  end
end
