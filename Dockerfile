FROM ubuntu:latest

RUN apt-get update && apt-get -y install wget \
	tar \
	make \
	cmake
WORKID \margot
RUN wget https://gitlab.com/margot_project/core/-/archive/master/core-master.tar.gz && \
	tar -xzvf core-master.tar.gz

