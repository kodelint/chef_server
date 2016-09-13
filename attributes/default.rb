default['chef_server']['url'] = 'https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.8.0-1_amd64.deb'

default['chef_server']['chef_fqdn'] = node['fqdn']

#Admin user related attributes
default['chef_server']['admin']['firstname'] = 'Satyajit'
default['chef_server']['admin']['lastname'] = 'Roy'
default['chef_server']['admin']['email'] = 'email2sroy@gmail.com'
default['chef_server']['admin']['username'] = 'uadmin'
default['chef_server']['admin']['user']['home'] = '/home/vagrant'
default['chef_server']['admin']['password'] = '123456'

# ORG Related attributes
default['chef_server']['orgname']['shortname'] = 'learnchef'
default['chef_server']['orgname']['fullname'] = 'Learnchef Inc'