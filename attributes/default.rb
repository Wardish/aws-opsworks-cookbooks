default["package"]["install"] = ["httpd24","php71","php71-mbstring","php71-common","php71-pdo","php71-xml","php71-pgsql","postgresql96-server","postgresql96"]
default["tz"] = "Asia/Tokyo"
default["application"]["database_location"] = "localhost"
default["application"]["database"]["host"] = "localhost"
default["application"]["database"]["username"] = ""
default["application"]["database"]["password"] = ""
default["application"]["database"]["database"] = ""

default["service"]["on"] = ["httpd","postgresql96"]