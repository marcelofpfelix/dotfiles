# ##############################################################################
#                                 FILE INFO
# lib for cli parsing
#
# using https://github.com/marcelofpfelix/boa
# ##############################################################################

# CLI=${CLI:="use: missing CLI definition"}

# If CLI is set, parse ARGs and CMDS
if [[ -n "${CLI+x}" ]]; then
    # parse the cli arguments
    result=$(echo "${CLI}" | boa "$@")
    readarray -t ARGS <<<"$result"
    # check if the help flag (last arguent) is present
    if [[ ${ARGS[-1]} != "false" ]]; then
        # print the help message
        echo "$result" | bat -p --paging=never -lhelp
        exit 1
    fi
    # replace spaces with _
    CMD="${ARGS[0]// /_}"
    read -a CMDS <<< "${ARGS[0]}" #TODO: delete
fi

# check if the subcommand is present and run it
subc() { #TODO: delete
    # if arguments over 1 run subcommand
    if [ $# -gt 0 ]; then
        $@
        exit
    fi
}

help() {
    if [[ -n "${CLI+x}" ]]; then
        echo "$CLI" | boa help | bat -p --paging=never -lhelp
    fi
}
