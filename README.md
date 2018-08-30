# AgoraProject
For this project I had to create a docker image that could launch the Agora server.

Agora server can be used to perform an online Design Space Exploration.
 
Agora server is a component of mARGOt. ( https://gitlab.com/margot_project/core )

mARGOt is a framework that provides to an application the ability to dinamically adapt in order to face changes
in the execution environment or in the application requirements.

The docker image is based on ubuntu:16.04.

# Dependencies
The agora server needs several dependencies to work:

C/C++ MQTT client implementation

MQTT broker (I used Mosquitto)

C/C++ Cassandra driver


# How to execute agora
There are 2 ways to execute the agora server.

The first one is to download directly the docker image, and then execute the following codeline:

#### docker pull gennaiolimick/agora
 
#### docker run –ti gennaiolimick/agora

The other one is to download the Dockerfile from the GitHub repository, build it and then run it.

Both methods are explained in the PowerPoint presentation with pictures to guide the user. 
https://github.com/Mick95/agoraProject/blob/master/Presentation.pptx
