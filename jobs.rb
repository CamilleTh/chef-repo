#
# Cookbook Name:: ci
# Recipe:: jobs
#
# Copyright 2012, InTech S.A.
#
# All rights reserved - Do Not Redistribute
#

apps=data_bag('apps')

# Config jobs directory
directory "#{node['jenkins']['server']['home']}/config-jobs" do
  	owner node['ci-server']['gitolite']['user']
  	group node['ci-server']['gitolite']['group']
end

# Create Jenkins job for all projects
apps.each do |app|
  job_config = "#{node['jenkins']['server']['home']}/config-jobs/#{app}-config.xml"

	jenkins_job app do
  		action :nothing
  		config job_config
	end

	template job_config do
  		source "sbt-job-config.xml.erb"
  		variables :repoPath => "git@#{node['hostname']}:#{app}"
  		notifies :update, resources(:jenkins_job => app), :immediately
      notifies :create, "ruby_block[save-job-#{app}]"
      notifies :get, "http_request[trigger-build-#{app}]"
	end

  http_request "trigger-build-#{app}" do
    url "#{node['jenkins']['server']['url']}/job/#{app}/build"
    action :nothing
  end

  ruby_block "save-job-#{app}" do
      block do
        node.set['ci-server']['jobs'][app] = "http://#{node['public_hostname']}:#{node['jenkins']['server']['port']}/job/#{app}"
        node.save
      end
      action :nothing
    end
end