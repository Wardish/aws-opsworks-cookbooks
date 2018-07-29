
package "git" do
  action :install
end

script "install-composer" do
  not_if "test -f /usr/local/bin/composer"
  interpreter "bash"
  user        "root"
  code <<-'EOS'
    cd /tmp
    curl -sS https://getcomposer.org/installer | php
    /bin/cp -f /tmp/composer.phar /usr/local/bin/composer
    chmod 755 /usr/local/bin/composer
  EOS
end

search("aws_opsworks_app").each_with_index do |app, i|
  file "/root/.ssh/#{app[:shortname]}.pem" do
    owner 'root'
    group 'root'
    mode 0600
    content app[:app_source][:ssh_key]
  end
  file "/root/#{app[:shortname]}-wrapper.sh" do
    mode 0755
    content "#!/bin/sh\nexec /usr/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/#{app[:shortname]}.pem \"$@\""
  end
  
  directory "/opt/apps" do
    owner 'apache'
    group 'apache'
    mode 0755
    action :create
    not_if { File.exists?("/opt/apps") }
  end

  directory "/var/www/apps" do
    owner 'apache'
    group 'apache'
    mode 0755
    action :create
    not_if { File.exists?("/var/www/apps") }
  end

  git "/opt/apps/#{app[:shortname]}" do
    repository "#{app[:app_source][:url]}"
    action :sync
    revision app[:app_source][:revision]
    ssh_wrapper "/root/#{app[:shortname]}-wrapper.sh"
  end

  service "httpd" do
    action [:stop]
  end

  script "app-release" do
    user "root"
    interpreter "bash"
    code <<-"EOS"
      /usr/bin/rsync -a --delete /opt/apps/#{app[:shortname]}/ /var/www/apps/#{app[:shortname]}/
      chown -R ec2-user /var/www/apps/#{app[:shortname]}
    EOS
  end

  script "app-build" do
    user "ec2-user"
    interpreter "bash"
    code <<-"EOS"
      cd /var/www/apps/#{app[:shortname]}/modules/#{app[:environment][:name]}
      /usr/local/bin/composer update
    EOS
  end


  template "/var/www/apps/#{app[:shortname]}/modules/#{app[:environment][:name]}/application/config/database.php" do
    not_if "test ! -d /var/www/apps/#{app[:shortname]}/modules/#{app[:environment][:name]}/application"
    source "database.php.erb"
    mode "0660"
    group "ec2-user"
    owner "ec2-user"
    variables({
        :database_host => app[:environment][:database_host],
        :database_user => app[:environment][:database_user],
        :database_password => app[:environment][:database_password],
        :database_name => app[:environment][:database_name]
    })
  end

  script "database-migrate" do
    user "ec2-user"
    interpreter "bash"
    code <<-"EOS"
      cd /var/www/apps/#{app[:shortname]}/modules/#{app[:environment][:name]}
      php public/index.php migrate latest
    EOS
  end

  template "/var/www/apps/#{app[:shortname]}/modules/#{app[:environment][:name]}/public/.htaccess" do
    source "htaccess.erb"
    mode "0660"
    group "ec2-user"
    owner "ec2-user"
    variables({
        :document_root => app[:attributes][:document_root],
        :ci_params => app[:environment].select {|key, val| key.start_with?("CI_")}
    })
  end

  script "owner-change" do
    user "root"
    interpreter "bash"
    code <<-"EOS"
      chown -R apache:apache /var/www/apps/#{app[:shortname]}
    EOS
  end

  service "httpd" do
    action [:start]
  end

end

