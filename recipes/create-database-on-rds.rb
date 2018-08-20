search("aws_opsworks_app" ,"deploy:true").each_with_index do |app, i|
  Chef::Log.info("create-database-on-rds #{app[:name]}")

  data_source = app[:data_sources].first

  if "RdsDbInstance" == data_source[:type] then
    Chef::Log.info("arn: #{data_source[:arn]}")

    arn = "#{data_source[:arn]}".gsub(/:/, '\:')
    rds_setting = search("aws_opsworks_rds_db_instance", "rds_db_instance_arn:#{arn}").first

    psql_list = "/usr/bin/psql -l -h #{rds_setting[:address]} -U '#{rds_setting[:db_user]}'"
    create_db = "/usr/bin/createdb -h #{rds_setting[:address]} -U '#{rds_setting[:db_user]}'"
    create_db_opt = "-E UTF-8 --locale=ja_JP.UTF-8 -T template0"

    script "create-database" do
      interpreter "bash"
      user "ec2-user"
      code <<-"EOS"
        echo '#{rds_setting[:address]}:5432:*:#{rds_setting[:db_user]}:#{rds_setting[:db_password]}' > /home/ec2-user/.pgpass
        chmod 0600 /home/ec2-user/.pgpass
        if ! #{psql_list} | awk '{print $1}' | grep '#{data_source[:database_name]}'; then
          #{create_db} -O '#{rds_setting[:db_user]}' #{create_db_opt} '#{data_source[:database_name]}'
        fi
      EOS
    end
  end
  
end