# ##############################################################################
#                                 FILE INFO
# lib with debug functions
#
# use https://github.com/charmbracelet/gum for more customizations
# ##############################################################################

# include libraries
LIBS_DIR=${LIBS_DIR:="$HOME/lib"}
. "$LIBS_DIR/lib_colors.sh"
. "$LIBS_DIR/lib_icon.sh"


# ##############################################################################
# Constants - global config
LOG_LEVEL=${LOG_LEVEL:=1}
LOG_TAG=${LOG_TAG:="11"}
#[[ -z "$LOG_LEVEL" ]] && LOG_LEVEL=1 # default log level is `NOTE`
#[[ -z "$LOG_TAG" ]] && LOG_TAG="11" # default log tag is `✅NOTE` (bits)


# ##############################################################################
# Functions

function log_level(){
    declare -A level_array=(
        # LOG LEVEL
        ['CRIT']=-2     # CRITICAL
        ['ERRO']=-1     # ERROR
        ['WARN']=0      # WARNING
        ['NOTE']=1      # NOTICE
        ['INFO']=2      # INFO
        ['DEBG']=3      # DEBUG

        # LOG STATUS
        ['FAIL']=-1     # FAIL
        ['CHGD']=0      # CHANGED
        ['OKAY']=1      # OKAY
        ['SKIP']=2      # SKIP
    )

    declare -A color_array=(
        [-2]='bp'        # Purple
        [-1]='br'        # Red
        [0]='by'         # Yellow
        [1]='bg'         # Green
        [2]='bb'         # Blue
        [3]='bc'         # Cyan
    )

    declare -A tag_array=(
        [-2]=$(icon crit)
        [-1]=$(icon erro)
        [0]=$(icon warn)
        [1]=$(icon note)
        [2]=$(icon info)
        [3]=$(icon debg)
    )

    # default is `1 g``
    local level=${level_array["$1"]:-1}
    local color=${color_array[$level]}

    # Check conditions and print accordingly
    if [ "${LOG_TAG:0:1}" == "1" ]; then
        tag_emoji=${tag_array[$level]}
    fi

    if [ "${LOG_TAG:1:1}" == "1" ]; then
        tag_desc="$1"
    fi
    tag="${tag_emoji}${tag_desc}"

    printf "$color $level $tag"
}


# ##############################################################################
# Prints coloured text
#
# Globals:
#     (RICHPY bool) if rich python colors are enabled
# Args:
#     [1]: (str) string to print
#     [N]: (cid: str) the color of each string
function printc() {
    # default color is bold blue
    local cid=${2:-bb}
    local color=$(color "$cid")
    local default=$(color "n")

    # if the color is n or invalid, then don't change the color
    if [[ $cid == "n" ]] || [[ -z ${COLOR["$cid"]} ]]; then
        printf "${1}"
        return
    fi

    echo -en "${color}${1}${default}"
}


# ##############################################################################
# Prints a multi-colour array of strings
#
# Args:
#     [1..N-1]: (str) array of strings to print
#     [N]: (colors: int)
#        1: color of each string
#        2: verbose level
#        3: identention
#        4: split char
#        5: newline
function println() {
    local settings
    local colors
    # parse the argument as an array ,
    IFS=',' read -a settings <<< "${!#}"
    # parse the first argument as an array :
    IFS=':' read -a colors <<< "${settings[0]}"
    local level=${settings[1]:-1}
    local tabs=${settings[2]:-0}
    local split=${settings[3]:-' '}
    local newline=${settings[4]:-1}
    local msg=$1 # "${1:-message_required}"

    # if the verbose level is above the current level, then return
    if (( $level > $LOG_LEVEL )); then
        return
    fi
    # print tabs
    for ((i = 0; i < tabs; i++ )); do
        printf "\t"
    done

    # print the first string
    printc "$msg" ${colors[0]}
    # loop through the strings
    for ((i = 2; i < $#; i++ )); do
        printc "${split}${!i}" ${colors[i-1]}
    done

    # print newline
    if [[ "$newline" -eq 1 ]]; then
        printf "\n"
    fi
}


# ##############################################################################
# Prints a coloured key-value
#
# Args:
#     [1]: (str) key
#     [2]: (str) value
#     [3]: (settings: int) println settings
function printkv() {
    # default settings
    local settings=${3:-"bb:n,"}

    println "$1:" "$2" "$settings"
}


# ##############################################################################
# Prints a log message
#
# Args:
#     [1]: (str) log level
#     [2]: (str) message
#     [N]: (str) last argument is the colors
function log() {
    local level
    local cid
    local tag
    local level
    # || true to be compatible with set -e
    level=$(log_level "$1") || true
    read cid level tag <<< "$level"

  #print key
    println "\t$tag:\t" $cid,$level,,,0

    shift

    # if the arguments are more than 2, then print the message
    if [[ $# -gt 1 ]]; then
        #echo here

        # color is the last argument
        #color="${!#}"
        #message=${@:1:$#-1}
        println "${@},${level}"
        return
    fi

    # print message
    println "${@}" "n,${level}"

}
#TODO:
# - add date_time (global config to enable/format)
# - add emoji to the log level (global config to enable)
# - no identention (global config to enable)
# - file, line number and function name (global config to enable)


# ##############################################################################

# Enhanced error handler
error_handler() {
  local exit_code=$?
  local line_no=${BASH_LINENO[0]}
  local func=${FUNCNAME[1]:-MAIN}
  local src_file=${BASH_SOURCE[1]:-$0}

  echo "❌ Error in ${src_file}:${line_no} (function: ${func})"
  echo "   Exit code: ${exit_code}"
  echo "   Command: ${BASH_COMMAND}"
}

trap error_handler ERR



# ##############################################################################











# ##############################################################################
# Deprecated

# ##############################################################################
# Prints coloured text
#
# Globals:
#     (RICHPY bool) if rich python colors are enabled
# Args:
#     [1]: (str) string to print
#     [N]: (cid: str) the color of each string
function printt() {
    # default color is bold blue
    cid=${2:-bb}

    # check if richpy is enabled
    if [[ $RICHPY ]]; then
        COLOR["$cid"]="${RPCOLOR["$cid"]}"
        COLOR["n"]="${RPCOLOR["n"]}"
    fi

    # if the color is n or invalid, then don't change the color
    if [[ $cid == "n" ]] || [[ -z ${COLOR["$cid"]} ]]; then
        printf "${1}"
        return
    fi

    printf "${COLOR["$cid"]}${1}${COLOR["n"]}"
}

# ##############################################################################


#dd a log function
# create a log function that outputs
# [10:10:36] ERROR    error message                                   logs.sh:32
# _self="${0##*/}" # name


# default settings
#color=${3:-"bb:n"}

# echo "$color,$level" #"${@:1:$#-1}"
#echo "$message" "${color},${level}"

# DATE_FORMAT=$(date +'%Y-%m-%d_%H:%M:%S')
# FILENAME="${_self%.*}"
# LINE="${BASH_LINENO[0]}" # or function name
# log funtion
# bash echo text into 2 columns right and left aligned
function logg(){

  LEVEl=$1 # pop the first argument
  shift # remove the first argument
  if [[ $LEVEL > $LOG_LEVEL ]] ; then
    echo "[] $LEVEl:\t$*"
  fi


}


# Sends to the stdout an Error message
echo_error() {
  printf "[$(date +'%Y-%m-%d_%H:%M:%S')] *ERROR:  %s\n"  "$*" >&2
}

# Sends to the stdout an Info message
echo_info() {
  if [[ $LOG_LEVEL == "INFO" || $LOG_LEVEL == "DEBUG" ]] ; then
    printf "[$(date +'%Y-%m-%d_%H:%M:%S')] INFO:    %s\n"  "$*"
  fi
}

# Sends to the stdout a Debug message
echo_debug() {
  if [[ $LOG_LEVEL == "DEBUG" ]] ; then
    printf "[$(date +'%Y-%m-%d_%H:%M:%S')] DEBG:   %s\n"  "$*"
  fi
}

# Sends to the stdout a Debug of the called function name
echo_function() {
  echo_debug "  # Function: $*\n"
}
