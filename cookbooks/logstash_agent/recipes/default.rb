#
# Cookbook Name:: logstash_agent
# Recipe:: default
#
# Copyright 2013, Intech SA
#
# All rights reserved - Do Not Redistribute
#
# http://archive.apache.org/dist/tomcat/tomcat-7/v[VERSION]/bin/apache-tomcat-[VERSION].zip


case node["platform"]
when "debian", "ubuntu"  
	
	require 'json'

	directory "#{node['logstash']['dir']}" do
		  owner "root"
		  group "root"
		  mode 0755 
		  action:create
	end

	remote_file "#{node['logstash']['dir']}/logstash.jar" do
		mode "0755"
		owner "root"
	  	group "root"
		source "http://192.168.1.60:8081/nexus/content/repositories/thirdparty/utils/logstash/1.1.13/logstash-1.1.13-flatjar.jar"
		action:create_if_missing	
	end

	listApp = ""
	env = ""
	first = 0

	node['DeployList'].each do |app| 
		app.each do |element|
			if( element[0] == "artefactid" ) 
				if (first == 0)
				listApp = element[1]
				first = 1
				else
				listApp = listApp + " " + element[1]
				end

			end
			if( element[0] == "env" ) 
				env = element[1]
			end
		end
	end	

	log listApp
	log env

	patterns = Array.new

	node['logtypes'].each do |type|
		
		t = String(type)
		t.tr! '"', ""
		t.tr! '[', ""
		t.tr! ']', ""

		pat = Array.new
		pat = t.split(',');
		pat[1] = pat[1].tr! ' ',""
		
		patterns.push({
				:name => pat[0],
				:url  => pat[1],
				:application => listApp,
				:environment => env
		})
		
	end

	template "logstash_agent.conf" do 
		mode "0755"
		source "logstash_agent.conf.erb"
		path "#{node['logstash']['dir']}/logstash_agent.conf"
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
