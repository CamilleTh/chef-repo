#
# Cookbook Name:: gitlab-client
# Recipe:: default
#
# Copyright 2013, ADE for InTech S.A.
#
# All rights reserved - Do Not Redistribute
#

# 1. Create new repositories
# 2. For each new repositories, publish a sample project

masterAccessLevel 	= node['gitlab']['masterAccessLevel']
developerAccessLevel 	= node['gitlab']['developerAccessLevel']

gitlabRestBaseURL = "http://#{node['gitlab']['host']}:#{node['gitlab']['port']}/api/v2"
gitlabToken = node['gitlab']['token']
gitlabUser = node['gitlab']['user']

devaasDir = node['gitlab']['devaasDirectory']
defaultBranch = node['git']['defaultBranch']

directory "#{devaasDir}" do
	user 	"gitlab"
	action :create
end

directory "#{devaasDir}/temp" do
	user 	"gitlab"
	action :create
end

git "#{devaasDir}/sample_j2ee" do
  repository node["git"]["sampleappRepo"]
  action :sync
  user "gitlab"
end

require 'rest_client'

applications = data_bag "apps"

applications.each do|app|
	appli = data_bag_item("apps", app)
	groupid = appli['groupid']
	envlist = ""
	envs = appli['envs']
	envs.each do |env|

		envname = env['name']
		if( envname != "Dev")  # master id the dev branch by default
			envlist = envlist + envname + " "
		end
	end 	


	ruby_block "Create repository #{appli.id}" do
		currentRepos = JSON.parse( RestClient.get "#{gitlabRestBaseURL}/projects?private_token=#{gitlabToken}" )
		currentUsers = JSON.parse( RestClient.get "#{gitlabRestBaseURL}/users?private_token=#{gitlabToken}" )

		block do
			alreadyExists=false
			unless currentRepos.nil?
				alreadyExists = currentRepos.find{|r| r['name'] == appli['id']} != nil
			end
			Chef::Log.info "Repository #{appli['id']} exists ? #{alreadyExists}"
			if !alreadyExists
				Chef::Log.info "Create repository #{appli['id']} with default branch #{defaultBranch}"
				res = RestClient.post "#{gitlabRestBaseURL}/projects?private_token=#{gitlabToken}", 
								{ 
									'name' => appli['id'],
									'default_branch' => defaultBranch
								}.to_json, 
								:content_type => :json
				if res.code == 201
					newRepoId = JSON.parse(res)['id']
					Chef::Log.info "Repository #{appli['id']} created with id #{newRepoId}!"
					appli['users'].each do|master|
						
						
						masterUser = currentUsers.find{|r| r['name'] == master['username']}
						if masterUser != nil
							Chef::Log.info "Add user #{masterUser['name']} as master to repo #{appli['id']}"
							RestClient.post "#{gitlabRestBaseURL}/projects/#{newRepoId}/members?private_token=#{gitlabToken}",
							{ 'id'=> newRepoId,
							 	'user_id'=> masterUser['id'], 
							 	'access_level'=> masterAccessLevel
							}.to_json
						else
							Chef::Log.info "Cannot find user #{master} in Gitlab"
						end
					end
				else
					Chef::Log.error "An error occured : response is #{res.code} with message #{res.to_str}"
				end
				if !alreadyExists
					Chef::Log.info "!exists"
					sleep 5
					resources(:script => "Init repository #{appli.id} #{groupid}").run_action(:run)
					appname = appli.id.downcase
					Chef::Log.info "git@192.168.11.27:#{gitlabUser}/#{appname}.git"
					node.normal['repositories'][appli.id] = "git@192.168.11.27:#{gitlabUser}/#{appname}.git"
				else
					Chef::Log.info "exists"
				end
			end
		end
		action :create
	end

	script "Init repository #{appli.id} #{groupid}" do
	  interpreter "bash"
	  user "gitlab"
	  cwd "#{devaasDir}/temp"
	  code <<-EOH
	  	mkdir repo_#{appli.id}
	  	cd repo_#{appli.id}
	  	
	  	appname=#{appli.id}
	  	git clone git@localhost:#{gitlabUser}/${appname,,}.git >> /tmp/1.log 2>> /tmp/2.log #tolowercase
	  	
	  	cd ${appname,,} #tolowercase
	  	cp -r #{devaasDir}/sample_j2ee/* .
	  	sed -i 's/ARTEFACT_ID/#{appli.id}/g' pom.xml 
		sed -i 's/GROUP_ID/#{groupid}/g' pom.xml 

	  	git add -A
	  	git commit -m "First commit"
	  	git branch #{defaultBranch}
	  	git checkout #{defaultBranch}
	  	git push -u origin #{defaultBranch}
	  	
  	 	for branch in #{envlist}
  		do
	  		git branch $branch
	  		git push origin $branch
		done
	  	cd #{devaasDir}/temp
	  	rm -rf #{devaasDir}/temp/repo_#{appli.id}
	  EOH
	  action :nothing
	end

end