#
# Cookbook Name:: logstash_service
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node["platform"]
when "debian", "ubuntu"  
	

	directory "#{node['logstash']['dir']}" do
		  owner "root"
		  group "root"
		  mode 0755
		  action:create
	end	

	template "logstash.conf" do 
		mode "0755"
		owner "root"
		group "root"
		source "logstash.conf.erb"
		path "#{node['service']['dir']}/logstash.conf"
	end
end
