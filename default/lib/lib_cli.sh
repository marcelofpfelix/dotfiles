# ##############################################################################
#                                 FILE INFO
# lib for cli parsing
#
# using https://github.com/marcelofpfelix/boa
# ##############################################################################


# parse the cli arguments
result=$(echo "$CLI" | boa "$@")
readarray -t ARGS <<<"$result"
# check if the help flag (last arguent) is present
if [[ ${ARGS[-1]} != "false" ]]; then
    # print the help message
    echo "$result"
    exit 1
fi
read -a CMDS <<< "${ARGS[0]}"
