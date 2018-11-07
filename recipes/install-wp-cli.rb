#
# Cookbook:: aws-opsworks-cookbooks
# Recipe:: install-wp-cli
#
# Copyright:: 2018, Wardish,LLC. All Rights Reserved.
script "install-wp-cli" do
  not_if "test -f /usr/local/bin/wp"
  interpreter "bash"
  user        "root"
  code <<-'EOS'
    cd /tmp
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar    /bin/cp -f /tmp/composer.phar /usr/local/bin/composer
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
  EOS
end