FROM ubuntu:16.04

#download package 
RUN apt-get update && apt-get -y install build-essential gcc make cmake cmake-gui cmake-curses-gui
RUN apt-get update && apt-get -y install openssl
RUN apt-get -y install fakeroot fakeroot devscripts dh-make lsb-release
RUN apt-get -y install libssl-dev
RUN apt-get -y install doxygen graphviz
RUN apt-get update && apt-get -y install wget tar make git curl 
ENV DEBIAN_FRONTEND noninteractive
RUN export DEBIAN_FRONTEND="noninteractive"
RUN apt-get -y install php-pear php7.0-dev
RUN apt-get -y install libgmp-dev

#download of mARGOt
RUN wget https://gitlab.com/margot_project/core/-/archive/master/core-master.tar.gz && \
	tar -xzvf core-master.tar.gz 

WORKDIR /core-master

#download MQTT C 
RUN git clone https://github.com/eclipse/paho.mqtt.c && \
	cd paho.mqtt.c && git checkout -t origin/develop && \
	cmake -DPAHO_BUILD_STATIC=TRUE -DPAHO_WITH_SSL=TRUE -DPAHO_BUILD_DOCUMENTATION=TRUE -DMQTT_TEST_BROKER=tcp://localhost:1883 && \
	make  && make install 

#download MQTT C++
RUN	git clone https://github.com/eclipse/paho.mqtt.cpp && cd paho.mqtt.cpp && \
	#cmake -DPAHO_MQTT_C_PATH=/core-master/paho.mqtt.c && \
	make && make install
RUN apt-get -y install cxxtest

#download and install Cassandra
RUN wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.20.0/libuv_1.20.0-1_amd64.deb && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.20.0/libuv-dev_1.20.0-1_amd64.deb && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.9.0/cassandra-cpp-driver_2.9.0-1_amd64.deb && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.9.0/cassandra-cpp-driver-dev_2.9.0-1_amd64.deb
RUN dpkg --force-all -i libuv_1.20.0-1_amd64.deb && \
	dpkg -i libuv-dev_1.20.0-1_amd64.deb && \
	dpkg -i cassandra-cpp-driver_2.9.0-1_amd64.deb && \
	dpkg -i cassandra-cpp-driver-dev_2.9.0-1_amd64.deb 
RUN pecl channel-update pecl.php.net
RUN pecl install cassandra

RUN sh -c 'echo "extension=cassandra.so" > /etc/php/7.0/mods-available/cassandra.ini'
RUN phpenmod cassandra

RUN cmake -DCMAKE_CURRENT_SOURCE_DIR=../ && \
	cmake -DWITH_AGORA=ON /core-master && cmake -DWITH_TEST=ON /core-master &&  make && make install
CMD cmake

#TEST 
#RUN rm /core-master/margot_heel/margot_heel_if/config/*.conf && \
#	cd /core-master/margot_heel/margot_heel_if/ && \
#	wget https://gitlab.com/margot_project/tutorial/-/archive/master/tutorial-master.tar.gz && \
#	tar -xzvf tutorial-master.tar.gz && cd tutorial-master/ && \
#	cp config/*.conf /core-master/margot_heel/margot_heel_if/config/ && \
#	cd .. && mkdir build && cd build && cmake .. && make
