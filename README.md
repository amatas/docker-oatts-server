## OATTS Server Dockerfile


This repository is used to build [OATTS Server] Docker image.


### Port(s) Exposed

* `80 TCP`

### Base Docker Image

* [inclusivedesign/php](https://github.com/idi-ops/docker-php/)


### Volumes

* /var/www

### Download

    docker pull trace/oatts-server


#### Run `OATTS server`

A MySQL database is required, before launch the oatts application you must launch mysql server:

```
docker run -d --name db -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=oatts -e MYSQL_USER=oatts -e MYSQL_PASSWORD=oattspw mysql
```

Now, create OATTS tables:

```
docker run -it --rm \
-e DBUSER=oatts \
-e DBPASSWORD=oattspw \
-e DBDB=oatts \
-e LOADDB=yes \
--link db:database trace/oatss-server
```

Finally launch the application container:

```
docker run -d -p 8081:80 \
-e SERVER_NAME=localhost \
-e DBUSER=oatts \
-e DBPASSWORD=oattspw \
-e DBDB=oatts \
-e BASEIP=127.0.0.1:8081 \
-e BASEDIR="" \
-e SQL_SECURE="false" \
-e HTTP_SECURE="false" \
-e DEBUG="false" \
-e SERVER_NAME="localhost" \
--link db:database trace/oatss-server
```

### Build your own image

	This container takes the OATTS Server code from the `data` directory

    docker build --rm=true -t <your name>/oatts-server .
