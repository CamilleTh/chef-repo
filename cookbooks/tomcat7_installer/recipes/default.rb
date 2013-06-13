#
# Cookbook Name:: tomcat7_installer
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# http://archive.apache.org/dist/tomcat/tomcat-7/v[VERSION]/bin/apache-tomcat-[VERSION].zip


case node["platform"]
when "debian", "ubuntu"  

	package "tar"

	directory "#{node['tomcat7']['installDir']}" do
	  owner "root"
	  group "root"
	  mode 0755
	  action:create
	end

	directory "#{node['tomcat7']['logDir']}" do
	  owner "root"
	  group "root"
	  mode 0755
	  action:create
	end
	

	remote_file "#{node['tomcat7']['installDir']}/apache-tomcat-#{node['tomcat7']['version']}.tar.gz" do
		mode "0755"
		owner "root"
	  	group "root"
		source "http://archive.apache.org/dist/tomcat/tomcat-7/v#{node['tomcat7']['version']}/bin/apache-tomcat-#{node['tomcat7']['version']}.tar.gz"
		action:create_if_missing
	end

	execute "tar" do
		 user "root"
		 group "root"
		 cwd "#{node['tomcat7']['installDir']}"
		 command "tar zxf #{node['tomcat7']['installDir']}/apache-tomcat-#{node['tomcat7']['version']}.tar.gz"
		 creates "#{node['tomcat7']['installDir']}/apache-tomcat-#{node['tomcat7']['version']}"
		 action :run
	end

	template "tomcat-users" do 
		mode "0755"
		source "tomcat-users.conf.erb"
		path "#{node['tomcat7']['installDir']}/apache-tomcat-#{node['tomcat7']['version']}/conf/tomcat-users.xml"
	end

	template "server.xml" do 
		mode "0755"
		source "server.conf.erb"
		path "#{node['tomcat7']['installDir']}/apache-tomcat-#{node['tomcat7']['version']}/conf/server.xml"
	end

	execute "tomcat stop" do
		user "root"
		group "root"
		cwd "#{node['tomcat7']['installDir']}/apache-tomcat-#{node['tomcat7']['version']}/bin"
		command "./catalina.sh stop"
		action :run
	end

	execute "tomcat run" do
		user "root"
		group "root"
		cwd "#{node['tomcat7']['installDir']}/apache-tomcat-#{node['tomcat7']['version']}/bin"
		command "sudo ./catalina.sh run &"
		action :run
	end


end


