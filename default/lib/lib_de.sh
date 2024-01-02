################################################################################
#                                 FILE INFO
# lib for docker exec with shell selection
################################################################################


exec() {
    sudo docker exec -it "$container" env PS1='\['"$BBlue"'\]'$(hostname -s)'@\['"$BPurple"'\]'"$container"'\['"$BBlue"'\]:\w \['"$BPurple"'\]\$\['"$nocolor"'\] ' $1
    # /bin/bash $norcstring -i for no profile
}


de() {

    [ -z "$1" ] && dps && return 1
    container=$1
    shift;

    # if $@ is not empty execute it
    if [[ -z "$@" ]]; then
        # if $@ is empty run shell

        exec /bin/bash
        result=$?
        if [ $result -eq 127 ]; then
            exec /bin/ash
            result=$?
        elif [ $result -eq 127 ]; then
            exec /bin/sh
        elif [ $result -eq 127 ]; then
            echo "Shell not available: $container"
        elif [ $result -eq 1 ]; then
            # Container not found
            dps
        fi
    else
        # run a command
        sudo docker exec "$container" "$@"

        return $?
    fi

}
