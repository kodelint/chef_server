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

# Create Admin User
admin_user = "#{node['chef_server']['admin']['username']}"
admin_fn = "#{node['chef_server']['admin']['firstname']}"
admin_ln = "#{node['chef_server']['admin']['lastname']}"
admin_email = "#{node['chef_server']['admin']['email']}"
admin_password = "#{node['chef_server']['admin']['password']}"
admin_pem_file = "#{node['chef_server']['admin']['username']}.pem"

execute "Create Admin User => #{admin_user}" do
  command "chef-server-ctl user-create #{admin_user} #{admin_fn} #{admin_ln} #{admin_email} #{admin_password} --filename #{admin_pem_file}"
  action :run
  not_if { ::File.exist?("/tmp/chef-server-core.#{admin_user}.created") }
end

file "/tmp/chef-server-core.#{admin_user}.created" do
  Chef::Log.info("Creating the gaurd file")
  action :create
end
