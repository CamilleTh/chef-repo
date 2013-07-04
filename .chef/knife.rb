log_level                :info
log_location             STDOUT
node_name                'workstation'
client_key               '/home/camille/chef-repo/.chef/workstation.pem'
validation_client_name   'camille'
validation_key           '/home/camille/chef-repo/.chef/workstation.pem'
chef_server_url          'https://192.168.11.27'
syntax_check_cache_path  '/home/camille/chef-repo/.chef/syntax_check_cache'
cookbook_path [ '/home/camille/chef-repo/cookbooks' ]
