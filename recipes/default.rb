#
# Cookbook Name:: nfs
# Recipe:: default 
#
# Copyright 2011, Eric G. Wolfe
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

# Install package, dependent on platform
node['nfs']['packages'].each do |nfspkg|
  package nfspkg
end

# Configure NFS client components
node['nfs']['config']['client_templates'].each do |client_template|
  template client_template do
    mode 0644
    notifies :restart, "service[portmap]"
    notifies :restart, "service[nfslock]"
  end
end

# Start NFS client components
service "portmap" do
  case node['platform']
  when "ubuntu"
    if node["platform_version"].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  service_name node['nfs']['service']['portmap']
  action [ :start, :enable ]
  supports :status => true
end

service "nfslock" do
  case node['platform']
  when "ubuntu"
    if node["platform_version"].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  service_name node['nfs']['service']['lock']
  action [ :start, :enable ]
  supports :status => true
end
