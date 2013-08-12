#
# Cookbook Name:: jenkinsjobs
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
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
		
	apps=data_bag('apps')

	directory node['jenkins']['dir'] do
	  owner 'root'
	  group 'root'
	  action :create
	end

	cookbook_file "#{node['jenkins']['dir']}/post_build.rb" do
	  source "post_build.rb"
	  mode 0755
	  owner "root"
	  group "root"
	end

	remote_file "#{node['jenkins']['dir']}/jenkins-cli.jar" do
		mode "0755"
		owner "root"
	  	group "root"
		source "#{node['nexus']['url']}/nexus/content/repositories/thirdparty/utils/jenkins-cli/1.0/jenkins-cli-1.0.jar"
		action :create_if_missing	
	end

	# Config jobs directory
	# Create Jenkins job for all projects
	apps.each do |app|

		#Get List Env
		appli = data_bag_item("apps",app)

		envs = appli['envs']

		gitrepo = node['repositories'][app]
		appname = appli.id
		groupid = appli['groupid']
		log appname


		envs.each do |env|
			envname = env["name"]	
			branch = envname
			repo = node['jenkins']['dir']+"/#{appname}#{envname}"

			if branch == "Dev" 
				branch = "master"
			end

			directory node['jenkins']['dir']+"/#{appname}#{envname}" do
			  owner 'root'
			  group 'root'
			 
			  action :create
			  notifies :create, "template[job_config #{appname}#{envname}]", :immediately
			end

			template "job_config #{appname}#{envname}" do
				mode "0755"
		  		source "j2ee-job-config.xml.erb"
		  		variables(:repoPath => gitrepo, :appname => appname, :envname => envname, :branch => branch, :groupid => groupid)	
				path repo+"/config.xml"
				notifies :create, "ruby_block[editjob #{appname} #{envname}]", :immediately
			end

			ruby_block "editjob #{appname} #{envname}" do
				block do
			 	  	jobexists = `java -jar  #{node['jenkins']['dir']}/jenkins-cli.jar -s #{node['jenkins']['server-url']} list-jobs | grep #{appname}#{envname}`
			 	  	Chef::Log.info "jobexist"+jobexists
				  	if (jobexists != "") 
				  		Chef::Log.info "update-job"
				   		`java -jar #{node['jenkins']['dir']}/jenkins-cli.jar -s #{node['jenkins']['server-url']} update-job #{appname}#{envname} < #{node['jenkins']['dir']}/#{appname}#{envname}/config.xml`
				  	else
				  		Chef::Log.info "create-job"
				  		`java -jar #{node['jenkins']['dir']}/jenkins-cli.jar -s #{node['jenkins']['server-url']} create-job #{appname}#{envname} < #{node['jenkins']['dir']}/#{appname}#{envname}/config.xml`
				  	end
				  	`curl #{node['jenkins']['server-url']}/job/#{appname}#{envname}/build`
			  	end

			  	action :nothing
			end
		end
	end
end