## OATTS Server Dockerfile

This repository is used to build [OATTS Server](https://github.com/GPII/open-access-tool-tray-system) Docker image.

### Port(s) Exposed

* `80 TCP`

### Base Docker Image

* [inclusivedesign/php](https://github.com/idi-ops/docker-php/)

### Volumes

* /var/www

### Download

If the container is available in [Docker Hub Registry](https://registry.hub.docker.com/) you can run this command to fetch a already built container:

```
 docker pull trace/oatts-server
```

### Build the container

Also, you can build the container using the source code of this git repository:

1. Clone this repository
  
  ```
  git clone https://github.com/gpii-ops/docker-oatts.git
  ```

2. Clone the source data of OATTS

  ```
  cd docker-oatts/
  git clone https://github.com/GPII/controllable-crowd-caption-correction.git src
  cp -a src/OATTS\ Server-Side data
  ```
 
3. Build the container

  ```
  docker build --rm=true -t trace/oatts .
  ```


### Run `OATTS server`

1. A MySQL database is required, before launch the oatts application you must launch mysql server:

  ```
  docker run -d \
  --name db \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=oatts \
  -e MYSQL_USER=oatts \
  -e MYSQL_PASSWORD=oattspw mysql
  ```

2. Now, create OATTS tables:

  ```
docker run -it --rm \
-e DBUSER=oatts \
-e DBPASSWORD=oattspw \
-e DBDB=oatts \
-e DBHOST=database \
-e LOADDB=yes \
--link db:database trace/oatss-server
```

3. Finally launch the application container:

  ```
docker run -d -p 8081:80 \
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

The application will listen by the 8081 port. 

For example, If an application will use the url: http://ccc.raisingthefloor.org/oatts/ its variables must be:

```
BASEIP="ccc.raisingthefloor.org"
SERVER_NAME="ccc.raisingthefloor.org"
BASEDIR="oatts"
```

## Development and testing

  A Vagrantfile is provided in order to make easier the testing and the development of the application. [Vagrant application](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) are needed to boot a virtual machine with all the stuff inside it.

  The application source must be in the "data" directory, and any change made in that directory will be reflected in the running application.

  ```
  git clone https://github.com/gpii-ops/docker-oatts.git
  cd docker-oatts
  git clone https://github.com/GPII/controllable-crowd-caption-correction.git src
  cp -a src/OATTS\ Server-Side data
  ```
  
  Once Vagrant is installed to boot up the virtual machine run the following command:

  ```
  vagrant up
  ```

  The application is served through the 127.0.0.1:8888 port of the local machine.

  *The first time that you run this command Vagrant downloads some image files, so this proccess takes some time.*

### Shutdown the virtual machine:
  ```
  vagrant halt
  ```

### Access to the virtual machine using SSH:

  ```
  vagrant ssh
  ```

### Redeploy the components

  If you need to deploy all the docker containers in the virtual machine run:

  ```
  vagrant provision
  ```

### Reset the environment

  If you want to start from the beggining: destroy the vm and create a new one:

  ```
  vagrant destroy
  vagrant up
  ```
