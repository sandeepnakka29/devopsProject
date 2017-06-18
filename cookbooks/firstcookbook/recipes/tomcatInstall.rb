
###updating libraries###
execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
end

###installing tomcat7###
package 'tomcat7' do
        action :install
end

###Clearing tomcat7 webapps ROOT folder###
bash 'Clearing tomcat7 webapps ROOT folder' do
  user 'root'
  cwd '/home/ubuntu'
  code <<-EOH
  sudo rm -rf /var/lib/tomcat7/webapps/ROOT
  EOH
end
 
###copying and replacing existing ROOT.war with new ROOT.war in our cookbook files/default directory###
cookbook_file "/var/lib/tomcat7/webapps/onewar.war" do
  source "onewar.war"
  mode "0644"
 # notifies :restart, "service[tomcat7]"
end

###restarting tomcat7 service###
service 'tomcat7' do
  supports :restart => true
end

# open standard ssh port
firewall_rule 'ssh' do
  port     22
  command  :allow
end

# open standard http port to tcp traffic only; insert as first rule
firewall_rule 'http' do
  port     80
  protocol :tcp
  position 1
  command   :allow
end
