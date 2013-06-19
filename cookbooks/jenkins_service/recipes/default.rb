#
# Cookbook Name:: jenkins_service
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

	template "jenkins.conf" do 
		mode "0755"
		owner "root"
		group "root"
		source "jenkins.conf.erb"
		path "#{node['service']['dir']}/jenkins.conf"
	end
end
