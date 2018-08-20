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