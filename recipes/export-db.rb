search("aws_opsworks_app" ,"deploy:true").each_with_index do |app, i|
  Chef::Log.info("create-database-on-local #{app[:name]}")

  data_source = app[:data_sources].first

  if "RdsDbInstance" == data_source[:type] then
    arn = "#{data_source[:arn]}".gsub(/:/, '\:')
    rds_setting = search("aws_opsworks_rds_db_instance", "rds_db_instance_arn:#{arn}").first

    template "/home/ec2-user/dropbox_upload.sh" do
      source "dropbox_upload.sh.erb"
      cookbook 'aws-opsworks-cookbooks'
      mode "0777"
      group "ec2-user"
      owner "ec2-user"
      variables(:dropbox_token => node['dropbox-token'])
    end

    environment = app[:environment]

    script "export" do
      interpreter "bash"
      user "ec2-user"
      code <<-"EOS"

cmd="psql95 -h #{rds_setting[:address]} -U #{rds_setting[:db_user]} #{data_source[:database_name]}"
cd /home/ec2-user
export HOME="/home/ec2-user"
echo "#{rds_setting[:address]}:5432:#{data_source[:database_name]}:#{rds_setting[:db_user]}:#{rds_setting[:db_password]}" > .pgpass
chmod 600 .pgpass
sudo chown ec2-user:ec2-user .pgpass
export PGPASSFILE=$HOME/.pgpass

mkdir -p "#{data_source[:database_name]}"

$cmd -c "\\dt" | grep tb_ | grep -v hist | awk '{print $3}'> "#{data_source[:database_name]}/tables"

for tb in `cat #{data_source[:database_name]}/tables`; do $cmd -c "COPY $tb TO stdout WITH CSV delimiter E'\\t' FORCE quote * NULL AS '' HEADER" > "#{data_source[:database_name]}"/$tb.txt; done


for file in `find #{data_source[:database_name]} -type f | grep txt`; do
  sh ./dropbox_upload.sh $file
done

rm -f *.txt
      EOS
    end
  end
end