script "setup-php" do
  interpreter "bash"
  user        "root"
  code <<-"EOS"
    export INI=/etc/php.ini
    sed -i 's@upload_max_filesize = 2M@upload_max_filesize = 10M@' ${INI}
    sed -i 's@post_max_size = 8M@post_max_size = 16M@' ${INI}
    sed -i 's@;date.timezone =@date.timezone = "Asia/Tokyo"@' ${INI}
    sed -i 's@; max_input_vars = 1000@max_input_vars = 2048@' ${INI}
    sed -i 's@memory_limit = 128M@memory_limit = 512M@' ${INI}
  EOS
end