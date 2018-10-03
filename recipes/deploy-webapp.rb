
search("aws_opsworks_app", "deploy:true").each_with_index do |app, i|
 
  module_path = app[:environment][:module_path] ? "#{app[:environment][:module_path]}" : "/"

  script "app-deploy" do
    user "root"
    interpreter "bash"
    code <<-"EOS"
      mkdir -p /var/www/apps
      cd "/opt/build/#{app[:shortname]}"
      rsync -a .#{module_path} /var/www/apps/#{app[:shortname]}/
    EOS
  end

  template "/var/www/apps/#{app[:shortname]}/#{app[:environment][:CI_PUBLIC]}/.htaccess" do
    only_if "test -f /var/www/apps/#{app[:shortname]}/#{app[:environment][:CI_PUBLIC]}/.htaccess"
    source "htaccess.erb"
    mode "0660"
    group "ec2-user"
    owner "ec2-user"
    variables({
        :document_root => app[:attributes][:document_root],
    })
  end

  script "owner-change" do
    user "root"
    interpreter "bash"
    code <<-"EOS"
      chown -R apache:apache /var/www/apps/#{app[:shortname]}
    EOS
  end

  data_source = app[:data_sources].first
  if "RdsDbInstance" == data_source[:type] then
    arn = "#{data_source[:arn]}".gsub(/:/, '\:')
    Chef::Log.info("RDS DB Instance #{arn}")
    rds_setting = search("aws_opsworks_rds_db_instance", "rds_db_instance_arn:#{arn}").first
    app[:environment][:WP_DB_NAME] = data_source[:database_name]
    app[:environment][:WP_DB_USER] = rds_setting[:db_user]
    app[:environment][:WP_DB_PASSWORD] = rds_setting[:db_password]
    app[:environment][:WP_DB_HOST] = rds_setting[:address]

    app[:environment][:CI_DB_NAME] = data_source[:database_name]
    app[:environment][:CI_DB_USER] = rds_setting[:db_user]
    app[:environment][:CI_DB_PASSWORD] = rds_setting[:db_password]
    app[:environment][:CI_DB_HOST] = rds_setting[:address]
  end

  template "/etc/httpd/conf.d/#{app[:shortname]}.conf" do
    source "app.conf.erb"
    mode "0660"
    group "apache"
    owner "apache"
    variables({
        :base_dir => "/var/www/apps/#{app[:shortname]}/#{app[:environment][:CI_PUBLIC]}",
        :document_root => app[:attributes][:document_root],
        :ci_params => app[:environment].select {|key, val| key.start_with?("CI_")},
        :wp_params => app[:environment].select {|key, val| key.start_with?("WP_")}
        })
  end

  service "httpd" do
    action [:restart]
  end
end

