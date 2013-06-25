#
# Cookbook Name:: haproxy
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node["platform"]
when "debian", "ubuntu"  
	

	package "tar"

	directory "#{node['haproxy']['dir']}" do
		  owner "root"
		  group "root"
		  mode 0755
		  action:create
	end	

	remote_file "#{node['haproxy']['dir']}/haproxy-1.4.24.tar.gz" do
		mode "0755"
		owner "root"
	  	group "root"
		source "http://haproxy.1wt.eu/download/1.4/src/haproxy-1.4.24.tar.gz"
		action:create_if_missing
		notifies :run, "execute[tar]", :immediately

	end

	execute "tar" do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "tar -xvzf #{node['haproxy']['dir']}/haproxy-1.4.24.tar.gz"
		 action :nothing
		 notifies :run, "execute[move]", :immediately

	end

	execute "move" do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "mv haproxy-1.4.24/* ."
		 action :nothing
		 notifies :run, "execute[rm]", :immediately

	end

	execute "rm" do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "rm -rf haproxy-1.4.24"
		 action :nothing
		 notifies :run, "execute[make TARGET]", :immediately
	end

	execute 'make TARGET' do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "make TARGET=linux26 "
		 action :nothing
		 notifies :run, "execute[make install]", :immediately
	end	 

	execute 'make install' do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "make install"
		 action :nothing
	end	 


 	# it's what we need to feed
	frontend = Array.new
	backend = Array.new
	
	# APP PART
	appList = data_bag("apps")
	appList.each do |app|

		# app = "app-test"

		appli = data_bag_item("apps",app)

		envs = appli['envs']
		# envs = "[env-test,..."

		envs.each do |envi|

			# ENV PART
			envList = data_bag("envs")

			envList.each do |env|

				if env == envi 

					infoenv = data_bag_item("envs",envi)
					aliasname = infoenv['alias']

					frontend.push({
						:app  => app,
						:env  => env,
						:aliasname  => aliasname
					})

					# VM PART
					vms = infoenv['vms']
					# envs = "[env-test,..."

					vms.each do |vm2|

						
						vmList = data_bag("vms")

						vmList.each do |vm|

							if vm == vm2

								infoVM  = data_bag_item("vms",vm)
								ip  = infoVM['ip']
								port  = infoVM['port']
								name  = infoVM['id']


								backend.push({
											:app  => app,
											:env  => env,
											:name => name,
											:ip  => ip,
											:port => port
								})
							end
						end	
					end
				end
			end	
		end		
	end 	
	log frontend
	log backend

	template "haproxy.cfg" do 
		mode "0755"
		source "haproxy.cfg.erb"
		path "#{node['haproxy']['dir']}/haproxy.cfg"
		variables(:frontend => frontend, :backend => backend)

		notifies :run, "bash[stop haproxy]", :immediately
	end

	bash "stop haproxy" do
  		user "root"
  		cwd "#{node['haproxy']['dir']}"
  		code <<-EOH
  		pid=`pgrep haproxy`
  		kill -9 $pid
 		EOH
		action :nothing
	end	 

	execute 'launch haproxy' do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "sudo start haproxy"
	end	
end