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


# Download MQTT C++
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


# Install Plugins  
RUN cd .. && cd agora && cd plugins && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
	python get-pip.py && pip install --user --upgrade cassandra-driver
RUN cd .. && cd agora && cd plugins && apt-get update && apt-get -y install r-base r-base-dev r-cran-rgl
RUN cd .. && cd agora && cd plugins && \
	Rscript -e "install.packages('Hmisc',repos = 'http://cran.rstudio.com/')" 
RUN cd .. && cd agora && cd plugins  && \ 
	Rscript -e "install.packages('crs', dependencies=TRUE,repos = 'http://cran.rstudio.com/')"


# Install mARGOT
RUN cmake -DCMAKE_CURRENT_SOURCE_DIR=../ -DWITH_AGORA=ON /core-master .. && make && make install


# Check for Cassandra
RUN echo "import time" >> check.py && \
echo "from cassandra.cluster import Cluster" >> check.py && \
echo "timer = 0 " >> check.py && \
echo "x = False " >> check.py && \
echo "while x == False: " >> check.py && \
echo "  time.sleep(1)" >> check.py && \
echo "  timer = timer + 1" >> check.py && \
echo "  print timer " >> check.py && \
echo "  try: " >> check.py && \
echo "    cluster = Cluster()" >> check.py && \
echo "    cluster.connect() " >> check.py && \
echo "    x=True " >> check.py && \
echo "  except: " >> check.py && \
echo "    if timer == 120:  " >> check.py && \
echo "      x=True " >> check.py 

# Indirizzo ip di questo docker è 172.17.0.2 e non 127.0.0.1
EXPOSE 1883

#CMD service cassandra start && mosquitto -d -p 1883 && python check.py && agora --workspace_folder /core-master/agora/build --plugin_folder /core-master/agora/plugins 

