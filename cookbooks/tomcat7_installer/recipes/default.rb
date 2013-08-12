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




	Apps = Array.new
	tomcatIsStop = 0
	updated = 0

	catalinaPID=`ps h -C java -o "%p:%a" | grep catalina | cut -d: -f1`
	log catalinaPID

	if catalinaPID == ""
		tomcatIsStop = 1
	end	  



	appCount = 0


	
	if !node.attribute?('DeployList')
		node.normal["DeployList"]
	end 

	node['DeployList'].each do |app|

		appInfo = String(app).split(',')

		App = Array.new
		
		appInfo.each do |info| 

			info.tr! '{', ""
			info.tr! '}', ""
			info.tr! '"', ""

			split = info.split('=>');
			App.push(split[1])
		end

		Apps.push(App)
	end
	                  
	#deploiement des applications
	Apps.each do |app|

		# if new version 
		if app[2] != app[3] 
      		
      		cmd1 = ""
		 	if app[2] .include? "SNAPSHOT"
				cmd1 = "wget 'http://#{node['nexus']['url']}/nexus/service/local/artifact/maven/redirect?r=snapshots&g=#{app[0]}&a=#{app[1]}&v=#{app[2]}&p=war' -O download.war"
		 	else
				cmd1 = "wget 'http://#{node['nexus']['url']}/nexus/service/local/artifact/maven/redirect?r=releases&g=#{app[0]}&a=#{app[1]}&v=#{app[2]}&p=war' -O download.war"
		 	end
			cmd2 = "curl -u admin:admin http://#{node['ipaddress']}:8080/manager/text/undeploy?path=/#{app[1]}"
			cmd3 = "curl -T - -u admin:admin 'http://#{node['ipaddress']}:8080/manager/text/deploy?update=true&path=/#{app[1]}' < download.war"
			cmd4 = "rm download.war"
			
			`#{cmd1}`
			`#{cmd2}`
			`#{cmd3}`
			`#{cmd4}`

			log appCount
			node.normal['DeployList'][appCount]['current_version'] = app[2] 
			appCount = appCount + 1

			# if new version is updated : restart tomcat
		    updated = 1
      	end 

	end

	if tomcatIsStop == 1 || updated == 1
		execute "tomcat stop" do
			user "root"
			group "root"
			cwd "#{node['tomcat7']['installDir']}/apache-tomcat-#{node['tomcat7']['version']}/bin"
			command "./catalina.sh stop"
			notifies :run, "execute[tomcat run]", :immediately
		end
	end

	execute "tomcat run" do
		user "root"
		group "root"
		cwd "#{node['tomcat7']['installDir']}/apache-tomcat-#{node['tomcat7']['version']}/bin"
		command "./catalina.sh run &"
		action :nothing
	end
	


end


