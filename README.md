# Node Projects Docker Based
With this base, you don't need to install npm or any other dependencies in your computer. The only thing you need to install is DOCKER! You can use this to develop node, react, angular projects as you like.

This project currently only support Linux/Mac OS well.

## Start
1. Clone the project on local computer.
2. Under Repository root, copy helper.sh and dev folder to your project(i.e my-project) by using
    `mkdir -p my-project && cp -r node-dev-docker-base/helper.sh node-dev-docker-base/dev my-project/`
3. Go to your project and change the helper.sh variable REPO_NAME to the name of your project
4. Start the helper.sh with
    `./helper.sh`
5. Select option 1 to build the Docker image
6. After image build successfully, image will not be able to start container in default. You need to use option 4 to interact with container cli first
7. For example, if you want to generate a react app, in container cli
`npm install create-react-app`
then
`./node-modules/.bin/create-react-app my-app`
my-app folder will automatically generate inside and outside the container
8. Then you need modify the Dockerfile to add container start command
```
ENV PROJECT_NAME my-app

RUN cd $PROJECT_NAME
CMD npm install --quiet &&\
    npm start
```
9. Now exit container interaction mode by using Ctrl+D and rerun option 1 to build the image again and run option 2 to start the server
10. You can use the similar way to install any app dependency inside container with option 4

## About the Image
The image default uses LTS node version with minimal OS image alpine. If you want to use any other version of node image, you can change it through dev/Dockerfile.
BTW, Alpine uses ash instead of bash.

## About the helper script
The script will help you create a bridge network and run the docker container inside that network.
You can use script to start or stop the container

## Others
People usually will confuse at first where your are: 
Inside the container or inside your local machine. 
Whenever you are in the interaction mode of container, the start character is #

## Any problem?
Create a issue and I'll try to fix it asap.