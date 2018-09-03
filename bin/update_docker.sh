#!/bin/bash
GREEN='\033[00;92m'
RED='\033[00;91m]'
RESTORE='\033[0m'
message=$(date "+%d/%m/%Y %H:%M")
message="$message (1 time a week)"

DOCKER_PATH="/home/fsx/docker/"
YAML_LIST=$(ls -1 ${DOCKER_PATH}*.yml)
KEY=

yaml_list () {
     for yaml in ${YAML_LIST}
         do
             docker-compose -f "${yaml}" pull
             echo -e "${yaml} ${GREEN} OK ${RESTORE}"
         done
}

if [[ "$1" == 'update' ]];then
    echo -e "${GREEN} Update argument passed, pulling new images... ${RESTORE}"
    yaml_list
fi



AUTOUPGRADE=$(docker ps -qf "label=autoupgrade") #-f "ancestor=$IMAGES") #CHECK CONTAINER WITH AUTOUPGRADE LABEL
IMAGES=$(docker ps --format "{{.ID}} {{.Image}}" --filter status=running | sed 's/\t/|/g;' | while read -r sROW; do echo "${sROW}" | awk '{print $2}'; done)

for IMAGE in ${IMAGES}
do
    echo -e "${GREEN} Check update for: ${IMAGE} ${RESTORE}"
#    if [[ ${IMAGE} != *":"* ]] && [[ ${AUTOUPGRADE} ]];then
    if [[ ${IMAGE} != *":"* ]];then
        echo "Cette image ne contient pas de tag : ${IMAGE}"
        ANCESTOR=$(docker ps --filter ancestor=${IMAGE} --format "{{.Names}}")
        echo "Image to update: ${ANCESTOR}"
        if [[ ${ANCESTOR} ]]; then
            echo "ANCESTOR PRESENT"
            for yaml in ${YAML_LIST}
            do
                COMPOSE=$(grep -lR "container_name: ${ANCESTOR}" ${yaml}) #RETRIEVE CONTAINER NAME IN COMPOSE.YML TO BUILD PATH
                if [[ ${COMPOSE} ]];then
                    docker-compose -f ${COMPOSE} rm -sf ${ANCESTOR} && docker-compose -f ${COMPOSE} up -d ${ANCESTOR}
                fi
#        PLEX_STATUS=$(curl -s https://url-of-tautulli/api/v2\?apikey=$KEY\&cmd=get_activity | jq --raw-output .response.data.stream_count)
#        if [[ $IMAGE = *"plexinc/pms-docker"* ]];then
#            echo "IMAGE is : $IMAGE & ANCESTOR is: $ANCESTOR"
#            echo "Check if Plex session running"
#            if [[ $PLEX_STATUS == 0 ]];then
#                echo -e "$GREEN No session running, Plex can be restarted if needed... $RESTORE"
#                echo "docker-compose -f $COMPOSE rm -sf $ANCESTOR && docker-compose -f $COMPOSE up -d $ANCESTOR"
#            else
#                echo -e "$RED Plex session running. $RESTORE"
#            fi
#        fi
            done
        fi
    else
        echo -e "$GREEN Nothing to do $RESTORE"
    fi
#        if [[ $IMAGE = *":"*  ]];then
#           message="$message\n &green $IMAGE up to date\n" && sendtobb localhost "status+7d xymon-docker.check_update green $(echo -e "$message")"
#        else
#            message="$message\n &yellow Containers need to be updated:\n $ANCESTOR\n" && sendtobb localhost "status+7d xymon-docker.check_update yellow $(echo -e "$message")"
#        fi
done
docker image prune -f

