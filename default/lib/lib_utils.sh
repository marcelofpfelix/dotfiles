################################################################################
#                                 FILE INFO
# lib with utility functions
################################################################################


# include libraries
. ../lib/lib_debug.sh

# ##############################################################################
# Constants - global config
export GUM_INPUT_PROMPT_FOREGROUND="#0FF"


# ##############################################################################
# Functions


function check_deps {
    # check that commands are available

    returnval=0
    for command in $DEPENDENCIES; do
        if ! which $command >/dev/null; then
            log ERRO "command" "$command" "is not available" n,bb,n
            returnval=1
        fi
    done


    return $returnval
}
