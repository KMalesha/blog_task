ruby 2.5.0
postgres 10.1


```
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
```

create db for test and development environment using psql
```
user=# CREATE DATABASE blog_development;
user=# CREATE DATABASE blog_test;
```

load schema on database
```
rake db:migrate
RACK_ENV=test rake db:migrate
```

run server:
```
  puma
```
run seed:
```
  rake db:seed
```
