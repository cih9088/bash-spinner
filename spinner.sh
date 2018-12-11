#!/bin/bash

# Author: Tasos Latsas
# Modified: Andy <cih9088@gmail.com>

# spinner.sh
#
# Display an awesome 'spinner' while running your long shell commands
#
# Do *NOT* call _spinner function directly.
# Use {start,stop}_spinner wrapper functions

# usage:
#   1. source this script in your's
#   2. start the spinner:
#       start_spinner [message]
#   3. run your command
#   4. stop the spinner:
#       stop_spinner [command's exit status] [meessage when success] [message when failed]
#
# Also see: test.sh


function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    #           $3 message length
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)
    #           $4 message length
    #           $5 message done
    #           $6 message failed

    local IGreen='[0;92m'
    local IRed='[0;91m'
    local IYellow='[0;93m'
    local Color_Off='[0m'

    case $1 in
        start)
            local msg=$2
            local ctr=$3

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\033[2K\033[${ctr}D${IYellow}[${sp:$((i++%${#sp})):1}]${Color_Off} ${msg}"
                sleep $delay
            done
            ;;
        stop)
            local exit_status=$2
            local pid=$3
            local ctr=$4
            local msg_done=$5
            local msg_failed=$6

            if [[ -z ${pid} ]]; then
                printf "spinner is not running..\n"
                exit 1
            fi

            kill ${pid} > /dev/null 2>&1

            # inform the user uppon success or failure
            if [[ ${exit_status} -eq 0 ]]; then
                printf "\033[2K\033[${ctr}D${IGreen}[*]${Color_Off} ${msg_done}\n"
            else
                printf "\033[2K\033[${ctr}D${IRed}[!]${Color_Off} ${msg_failed}\n"
                exit ${exit_status}
            fi
            ;;
        *)
            printf "invalid argument, try {start/stop}\n"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    # count mesg length
    ctr=4
    for (( i = 1; i <= $(printf "${1}" | expand | wc -m ); i++ )); do
        ctr=$(( $ctr + 1 ))
    done
    _spinner "start" "${1}" ${ctr} &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    # $2 : msg to display when done
    # $3 : msg to dispaly when failed
    
    _spinner "stop" ${1} ${_sp_pid} ${ctr} ${2:-DONE} ${3:-FAILED}
    unset _sp_pid
}

