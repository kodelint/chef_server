#
# Cookbook Name:: chef_server
# Recipe:: default
#
# Copyright (c) 2016 Satyajit Roy, All Rights Reserved.
package_url = node['chef_server']['url']
package_name = ::File.basename(package_url)
package_local_path = "#{Chef::Config[:file_cache_path]}/#{package_name}"

# package is remote, let's download it
remote_file package_local_path do
  source package_url
end

package package_name do
  source package_local_path
  provider Chef::Provider::Package::Dpkg
  notifies :run, 'execute[reconfigure-chef-server]', :immediately
end

file "/tmp/chef-server-core.firstrun" do
  action :create
end
# reconfigure the installation
execute 'reconfigure-chef-server' do
  command 'chef-server-ctl reconfigure'
  action :nothing
  not_if { File.exist?("/tmp/chef-server-core.firstrun") }
end
