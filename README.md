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
-e DBHOST=database \
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

### Development and testing

  A Vagrantfile is provided in order to make easy the testing and the development of the application. [Vagrant application](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) are needed to boot a virtual machine with all the stuff inside it.

  The application source must be in the "data" directory, and any change made in that directory will be reflected in the running application.

  The application is served through the 127.0.0.1:8888 port of the local machine.

  Once Vagrant is installed to boot up the virtual machine run the following command:

  ```
  vagrant up
  ```

  to shutdown the virtual machine:
  ```
  vagrant halt
  ```

  to access to the virtual machine using SSH:
  ```
  vagrant ssh
  ```


  If you need to deploy all the docker containers in the virtual machine run:

  ```
  vagrant provision
  ```

  If you want to start from the beggining: destroy the vm and create a new one:

  ```
  vagrant destroy
  vagrnat up
  ```
