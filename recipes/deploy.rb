node[:deploy].each do |application, deploy|
    if application[:environment][:is_ci] then
        template "#{deploy[:deploy_to]}/current/modules/codeigniter/public/.htaccess" do
            not_if "test ! -d #{deploy[:deploy_to]}/current/modules"
            source "htaccess.erb"
            mode "0660"
            group deploy[:group]
            owner deploy[:user]
            variables(:document_root => deploy[:document_root])
        end

        template "#{deploy[:deploy_to]}/current/modules/codeigniter/application/config/database.php" do
            not_if "test ! -d #{deploy[:deploy_to]}/current/modules"
            source "database.php.erb"
            mode "0660"
            group deploy[:group]
            owner deploy[:user]
            variables(:database => node[:application][:database_location] == "localhost" ? node[:application][:database] : deploy[:database])
        end

        script "update-composer" do
            not_if "test ! -d #{deploy[:deploy_to]}/current/modules"
            interpreter "bash"
            user "root"
            code <<-"EOS"
                cd #{deploy[:deploy_to]}/current/modules/codeigniter
                composer update
            EOS
        end

        script "migrate-database" do
            not_if "test ! -d #{deploy[:deploy_to]}/current/modules"
            interpreter "bash"
            user "root"
            code <<-"EOS"
                cd #{deploy[:deploy_to]}/current/modules/codeigniter
                php public/index.php migrate latest
            EOS
        end

        script "setup-application" do
            not_if "test ! -d #{deploy[:deploy_to]}/current/modules"
            interpreter "bash"
            user "root"
            code <<-"EOS"
                if [ -f #{deploy[:deploy_to]}/current/modules/setup.sh ]; then
                    sh #{deploy[:deploy_to]}/current/modules/setup.sh #{deploy[:document_root]}
                fi
            EOS
        end
    end
end
