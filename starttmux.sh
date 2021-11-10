#!/usr/bin/env bash

if [ "$#" -ne 4 ]; then
    printf "Arguments do not match.\nUSAGE: ./starttmux.sh NAME IMSI MSISDN KI\n"
    exit 1
fi

if ! command -v "tmux" &> /dev/null
then
    printf "Tmux could not be found. Install it to use this script.\n"
    exit 1
fi

if ! command -v "docker-compose" &> /dev/null
then
    printf "docker-compose could not be found. Install it to use this script.\n"
    exit 1
fi

NAME=$1
IMSI=$2
MSISDN=$3
KI=$4

docker-compose kill
docker-compose up -d

command="sleep 3 && docker-compose exec openbts-umts /OpenBTS/OpenBTS-UMTS; tmux kill-window"

if [ -z "${TMUX}" ]; then
    tmux new -d "$command"
else
    tmux new-window "$command"
fi

tmux rename-window "upenbts-umts"
tmux split-window -v "docker-compose exec openbts-umts sipauthserve"
tmux split-window -h "docker-compose exec openbts-umts /OpenBTS-UMTS/NodeManager/nmcli.py sipauthserve subscribers create $NAME $IMSI $MSISDN $KI && sleep infinity"
tmux select-pane -t 0

if [ -z "${TMUX}" ]; then
    tmux -2 attach-session -d
fi
