
search("aws_opsworks_app", "deploy:true").each_with_index do |app, i|

  script "migrate" do
    user "ec2-user"
    interpreter "bash"
    only_if "test -d /var/www/apps/#{app[:shortname]}/application"
    code <<-"EOS"
      cd "/var/www/apps/#{app[:shortname]}"
      /usr/bin/php public/index.php migrate latest
    EOS
  end
end

