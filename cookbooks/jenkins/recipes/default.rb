#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node["platform"]
when "debian", "ubuntu"  
	
	directory "#{node['jenkins']['dir']}" do
		  owner "root"
		  group "root"
		  mode 0755 
		  action:create
	end

	remote_file "#{node['jenkins']['dir']}/jenkins.war" do
		mode "0755"
		owner "root"
	  	group "root"
		source "#{node['jenkins']['url']}"
		action:create_if_missing	
	end

	service "logstash" do
		provider Chef::Provider::Service::Upstart
		action :start 
	end

end
