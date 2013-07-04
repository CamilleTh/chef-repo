#
# Cookbook Name:: deployApp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# recuperation des données 
Apps = Array.new

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
	log app
	log app[2]

	cmd1 = "wget 'http://#{node['nexus']['url']}/nexus/service/local/artifact/maven/redirect?r=releases&g=#{app[0]}&a=#{app[1]}&v=#{app[2]}&p=war' -O download.war"
	cmd2 = "curl -u admin:admin http://#{node['ipaddress']}:8080/manager/text/undeploy?path=/#{app[1]}"
	cmd3 = "curl -T - -u admin:admin 'http://#{node['ipaddress']}:8080/manager/text/deploy?update=true&path=/#{app[1]}' < download.war"
	cmd4 = "rm download.war"
	
	log cmd1
	log cmd2
	log cmd3
	`#{cmd1}`
	`#{cmd2}`
	`#{cmd3}`
	`#{cmd4}`
end