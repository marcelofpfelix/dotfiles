################################################################################
#                                 FILE INFO
# lib with utility functions
################################################################################

# Load libraries
LIBS_DIR=${LIBS_DIR:="$HOME/lib"}
. "$LIBS_DIR/lib_debug.sh"
. "$LIBS_DIR/lib_cli.sh"
. "$LIBS_DIR/lib_git.sh"
. "$LIBS_DIR/lib_status.sh"


# ##############################################################################
# Constants - global config
GUM_INPUT_PROMPT_FOREGROUND=${GUM_INPUT_PROMPT_FOREGROUND:="#0FF"} # default to use nerdfonts
#[[ -z "$GUM_INPUT_PROMPT_FOREGROUND" ]] && GUM_INPUT_PROMPT_FOREGROUND="#0FF"

export GUM_INPUT_PROMPT_FOREGROUND


# ##############################################################################
# Functions


function check_deps {
    # check that commands are available

    return_code=0
    for command in $DEPENDENCIES; do
        if ! which $command >/dev/null; then
            log ERRO "command" "$command" "is not available" n,bb,n
            returnval=1
        fi
    done


    return $return_code
}
