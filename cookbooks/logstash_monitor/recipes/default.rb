#
# Cookbook Name:: logstash_monitor
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

	Chef::Log.info("LOGGGG")


	remote_file "#{node['logstash']['dir']}/logstash.jar" do
		mode "0755"
		owner "root"
	  	group "root"
		source "http://192.168.4.131:8081/nexus/content/repositories/thirdparty/utils/logstash/1.1.13/logstash-1.1.13-flatjar.jar"
		action:create_if_missing	
	end

	logTypes = data_bag("logstash-types")
	patterns = Array.new
	
	logTypes.each do |type|
		value = data_bag_item("logstash-types",type)
		patterns.push({
			:id => value['id'],
			:pattern => value['pattern']
		})
	end

	
	template "logstash_monitor.conf" do 
		mode "0755"
		source "logstash_monitor.conf.erb"
		path "#{node['logstash']['dir']}/logstash_monitor.conf"
		variables(:patterns => patterns) 
	end

	service "logstash" do
		provider Chef::Provider::Service::Upstart
		action :stop 
	end 

	service "logstash" do
		provider Chef::Provider::Service::Upstart
		action :start 
	end

end
