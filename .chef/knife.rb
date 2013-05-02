log_level                :info
log_location             STDOUT
node_name                'camille'
client_key               '/home/camille/chef-repo/.chef/camille.pem'
validation_client_name   'chef-validator'
validation_key           '/home/camille/chef-repo/.chef/chef-validator.pem'
chef_server_url          'https://192.168.4.140'
syntax_check_cache_path  '/home/camille/chef-repo/.chef/syntax_check_cache'
cookbook_path [ '/home/camille/chef-repo/cookbooks' ]
