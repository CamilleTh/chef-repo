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
	


	execute "apt-get install haproxy " do
		 user "root"
		 group "root"
		 command "apt-get install haproxy -y"
		 action :run
	end

	execute "ENABLED = 1" do
		 user "root"
		 group "root"
		 command "sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/haproxy"
		 action :run
	end

 	# it's what we need to feed
	frontend = Array.new
	backend = Array.new
	
	appList = data_bag("apps")

	# for each app
	appList.each do |app|
	
		appli = data_bag_item("apps",app)
		envs = appli['envs']		

		# application name
		appName = appli['id']

		# port number
		port = appli['port']

		envs.each do |env|		
			env.each do |element|
				if element[0] == "name"
					#for each env

					# environnment name  
					envName = element[1]


					frontend.push({
						:app  => appName,
						:env  => envName
					})

					nodes = search('node', "DeployList_artefactid:"+appli['id']+" AND DeployList_env:"+envName)
					nodes.each do |node|
						ip = node["ipaddress"]
						vmname = node["fqdn"]
						log ip
						log vmname

						backend.push({
							:app  => appName,
							:env  => envName,
							:name => vmname,
							:ip  => ip,
							:port => port
						})
					end
				end
			end
		end
		log frontend
		log backend

	end

	template "haproxy.cfg" do 
		mode "0755"
		source "haproxy.cfg.erb"
		path "/etc/haproxy/haproxy.cfg"
		variables(:frontend => frontend, :backend => backend)
		notifies :run, "execute[restart haproxy]", :immediately
	end

	execute "restart haproxy" do
  		user "root"
  		group "root"
  		command "service haproxy restart"
		action :nothing
	end	 

end