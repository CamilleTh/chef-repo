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
		source "http://192.168.4.131:8081/nexus/content/repositories/thirdparty/utils/logstash/1.1.13/logstash-1.1.13-flatjar.jar"
		action:create_if_missing	
	end

	vmList= data_bag("vms")
	patterns = Array.new


	vmList.each do |vm|
		if (vm == Chef::Config[:node_name])
			value = data_bag_item("vms",vm)
			logtype  = value['logtypes']

			logtype.each {|name, url| 
				patterns.push({
					:name => name,
					:url  => url
				})
			}
		end
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
