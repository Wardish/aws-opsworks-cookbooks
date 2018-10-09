search("aws_opsworks_app", "deploy:true").each_with_index do |app, i|

  module_path = app[:environment][:module_path] ? "#{app[:environment][:module_path]}" : "/"

  script "app-copy" do
    user "root"
    interpreter "bash"
    code <<-"EOS"
      mkdir -p /opt/build
      /usr/bin/rsync -a --delete /opt/apps/#{app[:shortname]}/ /opt/build/#{app[:shortname]}/
      chown -R ec2-user /opt/build/#{app[:shortname]}
    EOS
  end

  script "app-build" do
    user "root"
    interpreter "bash"
    code <<-"EOS"
      cd "/opt/build/#{app[:shortname]}"
      if [ -f ./composer.json ]; then /usr/local/bin/composer install; fi

      cd "/opt/build/#{app[:shortname]}#{module_path}"
      if [ -f ./composer.json ]; then /usr/local/bin/composer install; fi
    EOS
  end
end