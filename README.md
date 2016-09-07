## chef_server + kitchen + vagrant
- **Description**: This will create **ubuntu-14.04** `Vagrant` machine and will install `chef-server` on it

#### Usages:
```bash
kitchen converge
```
* Default `.kitchen.yml`:
```
---
driver:
  name: vagrant

provisioner:
  name: chef_solo

platforms:
  - name: ubuntu-14.04
    driver:
      network:
        - ["private_network", {ip: "192.168.100.101"}]
      customize:
        memory: 1536
        natdnshostresolver1: "on"

suites:
  - name: server
    run_list:
      - recipe[chef_server::default]
    attributes:
```

- **Attributes**: Couple of attributes which you can toggle
```
default['chef_server']['admin']['firstname']
default['chef_server']['admin']['lastname']
default['chef_server']['admin']['username']
default['chef_server']['admin']['email']
default['chef_server']['admin']['password']
```
```
default['chef_server']['orgname']['shortname']
default['chef_server']['orgname']['fullname']
```
#### Aftermath:
* Receipe automatically creates the `Admin User` and `Organization`, just change the `attributes` if you want to change something
```
default['chef_server']['admin']['firstname']
default['chef_server']['admin']['lastname']
default['chef_server']['admin']['username']
default['chef_server']['admin']['email']
default['chef_server']['admin']['password']
```
```
default['chef_server']['orgname']['shortname']
default['chef_server']['orgname']['fullname']
```
* Create `.chef` directory `mkdir .chef`
* Get the `*.pem` files
```
scp -o stricthostkeychecking=no vagrant@192.168.100.101:/home/vagrant/admin.pem .chef/admin.pem
scp -o stricthostkeychecking=no vagrant@192.168.100.101:/home/vagrant/example-validator.pem .chef/example-validator.pem
```

* Create you `knife.rb`

```
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "uadmin"
client_key               "#{current_dir}/admin.pem"
validation_client_name   "example-validator"
validation_key           "#{current_dir}/example-validator.pem"
chef_server_url          "https://server-ubuntu-1404/organizations/example"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
```
* `SSL Error` if you get this:
```
ERROR: SSL Validation failure connecting to host: server-ubuntu-1404.vagrantup.com - SSL_connect returned=1 errno=0 state=error: certificate verify failed
ERROR: Could not establish a secure connection to the server.
Use `knife ssl check` to troubleshoot your SSL configuration.
If your Chef Server uses a self-signed certificate, you can use
`knife ssl fetch` to make knife trust the server's certificates.

Original Exception: OpenSSL::SSL::SSLError: SSL Error connecting to https://server-ubuntu-1404.vagrantup.com/organizations/example/cookbooks?num_versions=all - SSL_connect returned=1 errno=0 state=error: certificate verify failed
```
* Try `knife ssl fetch`, should see something like this
```
WARNING: Certificates from server-ubuntu-1404.vagrantup.com will be fetched and placed in your trusted_cert
directory (chef-repo/.chef/trusted_certs).

Knife has no means to verify these are the correct certificates. You should
verify the authenticity of these certificates after downloading.

Adding certificate for server-ubuntu-1404 in chef-repo/.chef/trusted_certs/server-ubuntu-1404.crt
```
* `knife ssl check` should give you something like this:
```
Connecting to host server-ubuntu-1404:443
Successfully verified certificates from `server-ubuntu-1404'
```
* Let's bring another `vagrant` box up and try chopping it using `knife`:
```
knife bootstrap 192.168.38.31 -x vagrant -P vagrant --sudo -N node1.vagrantup.com
```
* Now you are ready to write `cookbooks` upload them to **chef-server** using
```
knife cookbook upload cookbook_name
```
* Apply the `cookbook`
```
knife bootstrap 192.168.38.31 -N node1.vagrantup.com -r 'cookbook' --ssh-user vagrant --sudo --identity-file  ~/.vagrant.d/insecure_private_key
```
### TODO:
   * Create `Admin user` in the receipe (done)
   * Create `ORGANIZATION` in the receipe
   * Put the password in `databag`
   * Generate the `knife` configuration for workstation


