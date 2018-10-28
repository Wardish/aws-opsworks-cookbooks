require 'json'

%w(aws_opsworks_app
   aws_opsworks_command
   aws_opsworks_ecs_cluster
   aws_opsworks_elastic_load_balancer
   aws_opsworks_instance
   aws_opsworks_layer
   aws_opsworks_rds_db_instance
   aws_opsworks_stack
   aws_opsworks_user).each do |data_bag|
  puts '--------------------'
  puts "### #{data_bag} ###"
  search(data_bag).each_with_index do |app, i|
    puts "===== #{i} ====="
    puts JSON.pretty_generate(app)
  end
  puts '--------------------'
end