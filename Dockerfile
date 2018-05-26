FROM ubuntu:16.04


# Download package 
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
RUN apt-get -y install software-properties-common

# Download Mosquitto for MQTT 
RUN apt-add-repository ppa:mosquitto-dev/mosquitto-ppa && apt-get update && apt-get -y install mosquitto mosquitto-clients && /etc/init.d/mosquitto stop

# Download of mARGOt
RUN wget https://gitlab.com/margot_project/core/-/archive/master/core-master.tar.gz && \
	tar -xzvf core-master.tar.gz 


WORKDIR /core-master/agora/build

# Download MQTT C 
RUN git clone https://github.com/eclipse/paho.mqtt.c && \
	cd paho.mqtt.c && git checkout -t origin/develop && \
	mkdir build && cd build && cmake -DPAHO_BUILD_STATIC=TRUE -DPAHO_WITH_SSL=TRUE .. &&  \
	make  && make install 
#download MQTT C++
RUN git clone https://github.com/eclipse/paho.mqtt.cpp && cd paho.mqtt.cpp && mkdir build && cd build && cmake -DPAHO_WITH_SSL=TRUE .. && \
	make && make install
RUN apt-get -y install cxxtest

# Download and install Cassandra
RUN wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.20.0/libuv_1.20.0-1_amd64.deb && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.20.0/libuv-dev_1.20.0-1_amd64.deb && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.9.0/cassandra-cpp-driver_2.9.0-1_amd64.deb && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.9.0/cassandra-cpp-driver-dev_2.9.0-1_amd64.deb
RUN dpkg --force-all -i libuv_1.20.0-1_amd64.deb && \
	dpkg -i libuv-dev_1.20.0-1_amd64.deb && \
	dpkg -i cassandra-cpp-driver_2.9.0-1_amd64.deb && \
	dpkg -i cassandra-cpp-driver-dev_2.9.0-1_amd64.deb 


RUN echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list && \
	curl https://www.apache.org/dist/cassandra/KEYS | apt-key add - && \
	apt-get update && apt-get -y install cassandra

WORKDIR /core-master/build


# Install mARGOT
RUN cmake -DCMAKE_CURRENT_SOURCE_DIR=../ -DWITH_AGORA=ON /core-master .. 

CMD service cassandra start && mosquitto -d && make && make install && agora --workspace_folder /core-master/agora/build --plugin_folder /core-master/agora/plugins 


#WORKDIR /core-master/agora
#RUN mosquitto -d
#RUN  cassandra && service cassandra status
#RUN mosquitto -d  && agora --workspace_folder /core-master/agora/build --plugin_folder /core-master/agora/plugins

