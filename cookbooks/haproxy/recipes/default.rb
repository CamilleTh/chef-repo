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
	
	envActu = ""

	appList = data_bag("apps")
	appList.each do |app|
	
		appli = data_bag_item("apps",app)
		envs = appli['envs']
		
		port = appli['port']

		envs.each do |envi|
			
			bool = 0
			envi.each do |part|
				
				if bool == 0 
					bool = 1 
					envActu = part

					frontend.push({
						:app  => app,
						:env  => part
					})
				else
					part.each  do |vm|
		

						name = vm[0]
						ip   = vm[1]
						ip = ip.to_s
						ip.tr! '{', ""
						ip.tr! '}', ""
						ip.tr! '"', ""
						ip = ip.split("=>")
						ip = ip[1]


						backend.push({
							:app  => app,
							:env  => envActu,
							:name => name,
							:ip  => ip,
							:port => port
						})
					end
				end

			end	
		end	
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