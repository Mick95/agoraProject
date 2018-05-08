FROM gcc:latest 

WORKDIR /tmp/cmake
#download Cmake and unzip it
RUN wget https://cmake.org/files/v3.11/cmake-3.11.1.tar.gz && \
	tar -xzvf cmake-3.11.1.tar.gz > /dev/null

WORKDIR cmake-3.11.1

RUN ./bootstrap > /dev/null && \
    make -j$(nproc --all) > /dev/null && \
    make install > /dev/null

WORKDIR /
#remove installation file
RUN rm -rf /tmp/cmake