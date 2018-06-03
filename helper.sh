#/bin/bash!

# Color
INFO='\033[38;5;29m'    # Dark Green
TIP='\033[38;5;25m'     # Ocean Blue
ERROR='\033[38;5;124m'  # Red
END='\033[0m'       # No Color

# Virables
REPO_NAME=my-project
IMAGE_NAME=${REPO_NAME}
# To avoid interfere with other projects in the future, when using helper running up the service, give it a isolated network
NETWORK_NAME=${REPO_NAME}_network
PORT=3000

# Text Block
read -d '' instruction << EOM
jq(lightweight command-line JSON processor) is not installed. If you want the script fully functional, please follow the instruction:
Please install jq with following command:
# brew install jq
The waiting time to install it maybe a little bit longer than you expect
EOM

# Functions
install_jq(){
    # Check if the jq --version error output is zero length or not, if yes, then the jq is not installed
    if [ -z "$(jq --version 2>/dev/null)" ];then
        echo "${ERROR}$instruction${END}"
    fi
}

# Build the image
build_image(){
    echo "\n${INFO}Build ${REPO_NAME} image...${END}"
    docker build -f dev/Dockerfile -t ${REPO_NAME} --build-arg DEV_HOME=$(pwd) .
}

# Remove images
remove_image(){
    stop_and_rm_container_if_running ${REPO_NAME} &&\
    if [[ -n "$(docker images -q ${IMAGE_NAME})" ]];then
        echo "\n${INFO}Remove ${IMAGE_NAME} image...${END}" &&\
        docker rmi ${IMAGE_NAME}
    fi
}

# Precheck image
build_image_if_not_exist(){
    if [[ -z "$(docker images -q ${IMAGE_NAME})" ]];then
        build_image
    else 
        echo "${INFO}${IMAGE_NAME} already exists...${END}"
    fi
}

# Create the network
create_network(){
    if [[ $(docker network inspect ${NETWORK_NAME} 2>/dev/null | jq '. | length') == 0 ]];then
        echo "${INFO}Create network ${NETWORK_NAME}...${END}"
        docker network create ${NETWORK_NAME} --driver=bridge
    else
        echo "${INFO}${NETWORK_NAME} already exists...${END}"
    fi
}

start_app(){
    if [[ -z "$(docker ps -aqf "name=${REPO_NAME}")" ]]; then
        echo "${INFO}Start ${REPO_NAME}..." &&\
        docker run --rm -it --name ${REPO_NAME} -v $(pwd):$(pwd) -p ${PORT}:${PORT} --network ${NETWORK_NAME} ${IMAGE_NAME}
    else
        echo "${INFO}${REPO_NAME} is already up...${END}"
    fi
}

# Run the container in command mode
run_cli(){
    if [[ -n "$(docker ps -aqf "name=${REPO_NAME}")" ]]; then
        echo "${INFO}exec with current up container ${REPO_NAME}..." &&\
        docker exec -it ${REPO_NAME} ash
    else
        echo "${INFO}create a empheral container to access cli...${END}"
        docker run --rm -it --name ${REPO_NAME} -v $(pwd):$(pwd) -p ${PORT}:${PORT} --network ${NETWORK_NAME} ${IMAGE_NAME} ash
    fi
}


# Stop and remove single container
stop_and_rm_container_if_running(){
    # Filter the specific docker container by using its name and check the output is nonzero
    if [[ -n $(docker ps -aqf "name=$1") ]]; then
        echo "${INFO}Stop and remove $1...${END}" &&\
        docker stop $1 &&\
        # Check if the container still availabe and remove it if it is not auto removable
        if [ $(docker inspect $1 2>/dev/null | jq '.[0].HostConfig.AutoRemove') == "false" ]; then
            docker rm $1
        fi
    fi
}

# Stop and remove all of the containers
remove_all(){
    echo "${INFO}Stop and remove ${REPO_NAME}...${END}" &&\
    stop_and_rm_container ${REPO_NAME}
}

# Main
install_jq

echo "${INFO}Select one action:${END}"

actions=(
    "Build ${REPO_NAME} image"
    "Start ${REPO_NAME} container"
    "Stop ${REPO_NAME} container"
    "Run npm command through Docker"
    "Quit"
)

select action in "${actions[@]}"
do
    case ${action} in
        "${actions[0]}")
            remove_image && \
            build_image
            ;;
        "${actions[1]}")
            echo "\n${INFO}Start ${REPO_NAME}${END}"
            build_image_if_not_exist && \
            create_network && \
            start_app
            ;;
        "${actions[2]}")
            remove_all
            ;;
        "${actions[3]}")
            create_network && \
            run_cli
            ;;
        "${actions[4]}")
            break
            ;;
        *) echo "${ERROR} invalid action${END}";;
    esac
done
