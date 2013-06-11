#
# Cookbook Name:: logstash_agent
# Recipe:: default
#
# Copyright 2013, Intech SA
#
# All rights reserved - Do Not Redistribute
#

	directory "#{node['logstash']['dir']}" do
		  owner "root"
		  group "root"
		  mode 0755
		  action:create
	end

	remote_file "#{node['logstash']['dir']}/logstash-1.1.13-flatjar.jar" do
			mode "0755"
			owner "root"
		  	group "root"
			source "http://localhost:8081/nexus/content/repositories/thirdparty/utils/logstash/1.1.13/logstash-1.1.13-flatjar.jar"
			action:create_if_missing	
	end

	template "tomcat-users" do 
			mode "0755"
			source "tomcat-users.conf.erb"
			path "#{node['logstash']['dir']}/logstash_agent.conf"
	end


