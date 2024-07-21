################################################################################
#                                 FILE INFO
# lib with utility functions
################################################################################


# include libraries
. ../lib/lib_debug.sh
. ../lib/lib_cli.sh


# ##############################################################################
# Constants - global config
[[ -z "$GUM_INPUT_PROMPT_FOREGROUND" ]] && GUM_INPUT_PROMPT_FOREGROUND="#0FF" # default to use nerdfonts

export GUM_INPUT_PROMPT_FOREGROUND


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
