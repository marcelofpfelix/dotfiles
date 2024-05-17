################################################################################
#                                 FILE INFO
# lib with colors functions
#
# use https://github.com/charmbracelet/gum for more customizations
################################################################################


# ##############################################################################
# Constants - global config
RICHPY=0 # default richpy format is 0
LEMONBAR=0 # default lemonbar format is 0


declare -A color16=(
    ['surface0']='#313244'  # black
    ['red']='#f38ba8'       # red
    ['green']='#a6e3a1'     # green
    ['yellow']='#f9e2af'    # yellow
    ['blue']='#89b4fa'      # blue
    ['pink']='#f5c2e7'      # pink
    ['mauve']='#cba6f7'     # mauve
    ['text']='#cdd6f4'      # text

    ['overlay0']='#6c7086'   # overlay0
    ['marron']='#eba0ac'     # marron
    ['teal']='#94e2d5'       # teal
    ['peach']='#fab387'      # peach
    ['sky']='#89dceb'        # sky
    ['flamingo']='#f2cdcd'   # flamingo
    ['lavender']='#b4befe'   # lavender
    ['subtext0']='#a6adc8'   # subtext0

    ['rosewater']='#f5e0dc'  # rosewater
    ['sapphire']='#74c7ec'   # sapphire
    ['crust']='#11111b'      # crust
    ['mantle']='#181825'     # mantle
    ['base']='#1e1e2e'       # base
    ['surface1']='#45475a'   # surface1
    ['surface2']='#585b70'   # surface2
    ['overlay1']='#7f849c'   # overlay1
    ['overlay2']='#9399b2'   # overlay2
)


# ##############################################################################
# converts a color id to a color code
#
# Args:
#     [1]: (str) id of the color
function color() {
    # colours
    declare -A cid=(
        ['k']='0m'      # Black
        ['r']='1m'      # Red
        ['g']='2m'      # Green
        ['y']='3m'      # Yellow
        ['b']='4m'      # Blue
        ['p']='5m'      # Purple
        ['c']='6m'      # Cyan
        ['w']='7m'      # White
    )
    # style
    declare -A sid=(
        ['b']='1;3'     # bold
        ['u']='4;3'     # underline
        ['o']='4'       # on background
        ['i']='0;9'     # high intensity
        ['bi']='1;9'    # bold high intensity
        ['oi']='0;10'   # on high intensity backgrounds
    )
    escape='\033['
    style='0;3' # default is regular
    color='0m'  # default is black

    # check if richpy is enabled
    if [[ $RICHPY -eq 1 ]]; then
        # colours
        declare -A cid=(
            ['k']='[black]'      # Black
            ['r']='[red]'        # Red
            ['g']='[green]'      # Green
            ['y']='[yellow]'     # Yellow
            ['b']='[blue]'       # Blue
            ['p']='[magenta]'    # Purple
            ['c']='[cyan]'       # Cyan
            ['w']='[white]'      # White
        )
        # style
        declare -A sid=(
            ['b']='[bold ]'         # bold
            ['u']='[underline ]'    # underline
            ['o']='[on ]'           # on background
            ['i']='[bright_]'       # high intensity
            ['bi']='[bold bright_]' # bold high intensity
            ['oi']='[on bright_]'   # on high intensity backgrounds
        )
        escape=''
        style=''
        color='[default]'
    fi

    # check if richpy is enabled
    if [[ $LEMONBAR -eq 1 ]]; then
        # colours
        declare -A cid=(
            ['k']=${color16['surface0']} # Black
            ['r']=${color16['red']}      # Red
            ['g']=${color16['green']}    # Green
            ['y']=${color16['yellow']}   # Yellow
            ['b']=${color16['blue']}     # Blue
            ['p']=${color16['pink']}     # Purple
            ['c']=${color16['teal']}     # Cyan
            ['w']=${color16['text']}     # White
        )
        escape='%%{'
        style='F'
        color='F-'
        suffix='}'
    fi
    # if the size of the id is 1, then it's a color
    if [[ ${#1} == 1 ]]; then
        # if the is is n, the sytle is empty
        if [[ $1 == "n" ]]; then
            style=''
        else
            color=${cid[$1]}
        fi

    else
        #color is the last character
        color=${cid[${1:${#1}-1}]}
        # remove the last character for style
        style=${sid[${1:0:${#1}-1}]}
    fi
    printf "${escape}${style}${color}${suffix}"
}





base16="""
base00: "1e1e2e" # base
base01: "181825" # mantle
base02: "313244" # surface0
base03: "45475a" # surface1
base04: "585b70" # surface2
base05: "cdd6f4" # text
base06: "f5e0dc" # rosewater
base07: "b4befe" # lavender
base08: "f38ba8" # red
base09: "fab387" # peach
base0A: "f9e2af" # yellow
base0B: "a6e3a1" # green
base0C: "94e2d5" # teal
base0D: "89b4fa" # blue
base0E: "cba6f7" # mauve
base0F: "f2cdcd" # flamingo
"""



# ##############################################################################
# Deprecated - To be migrated
#
# https://stackoverflow.com/questions/26153308/best-ansi-escape-beginning

# Reset
nocolor='\033[0m'           # Text Reset

# Bold
bold='\033[1m'              # bold

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black  k
BRed='\033[1;31m'         # Red    r
BGreen='\033[1;32m'       # Green  g
BYellow='\033[1;33m'      # Yellow y
BBlue='\033[1;34m'        # Blue   b
BPurple='\033[1;35m'      # Purple p
BCyan='\033[1;36m'        # Cyan   c
BWhite='\033[1;37m'       # White  w

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

declare -A COLOR=(
    ['n']='\033[0m'         # No Style
    ['bn']='\033[1m'        # Bold

    # Regular Colors
    ['k']='\033[0;30m'      # Black
    ['r']='\033[0;31m'      # Red
    ['g']='\033[0;32m'      # Green
    ['y']='\033[0;33m'      # Yellow
    ['b']='\033[0;34m'      # Blue
    ['p']='\033[0;35m'      # Purple
    ['c']='\033[0;36m'      # Cyan
    ['w']='\033[0;37m'      # White

    # Bold
    ['bk']='\033[1;30m'     # Bold Black
    ['br']='\033[1;31m'     # Bold Red
    ['bg']='\033[1;32m'     # Bold Green
    ['by']='\033[1;33m'     # Bold Yellow
    ['bb']='\033[1;34m'     # Bold Blue
    ['bp']='\033[1;35m'     # Bold Purple
    ['bc']='\033[1;36m'     # Bold Cyan
    ['bw']='\033[1;37m'     # Bold White

    # Underline
    ['uk']='\033[4;30m'     # Underline Black
    ['ur']='\033[4;31m'     # Underline Red
    ['ug']='\033[4;32m'     # Underline Green
    ['uy']='\033[4;33m'     # Underline Yellow
    ['ub']='\033[4;34m'     # Underline Blue
    ['up']='\033[4;35m'     # Underline Purple
    ['uc']='\033[4;36m'     # Underline Cyan
    ['uw']='\033[4;37m'     # Underline White

    # On Background
    ['ok']='\033[40m'       # On Background Black
    ['or']='\033[41m'       # On Background Red
    ['og']='\033[42m'       # On Background Green
    ['oy']='\033[43m'       # On Background Yellow
    ['ob']='\033[44m'       # On Background Blue
    ['op']='\033[45m'       # On Background Purple
    ['oc']='\033[46m'       # On Background Cyan
    ['ow']='\033[47m'       # On Background White

    # High Intensity
    ['ik']='\033[0;90m'     # High Intensity Black
    ['ir']='\033[0;91m'     # High Intensity Red
    ['ig']='\033[0;92m'     # High Intensity Green
    ['iy']='\033[0;93m'     # High Intensity Yellow
    ['ib']='\033[0;94m'     # High Intensity Blue
    ['ip']='\033[0;95m'     # High Intensity Purple
    ['ic']='\033[0;96m'     # High Intensity Cyan
    ['iw']='\033[0;97m'     # High Intensity White

    # Bold High Intensity
    ['bik']='\033[1;90m'    # Bold High Intensity Black
    ['bir']='\033[1;91m'    # Bold High Intensity Red
    ['big']='\033[1;92m'    # Bold High Intensity Green
    ['biy']='\033[1;93m'    # Bold High Intensity Yellow
    ['bib']='\033[1;94m'    # Bold High Intensity Blue
    ['bip']='\033[1;95m'    # Bold High Intensity Purple
    ['bic']='\033[1;96m'    # Bold High Intensity Cyan
    ['biw']='\033[1;97m'    # Bold High Intensity White

    # On High Intensity backgrounds
    ['oik']='\033[0;100m'   # On High Intensity backgrounds Black
    ['oir']='\033[0;101m'   # On High Intensity backgrounds Red
    ['oig']='\033[0;102m'   # On High Intensity backgrounds Green
    ['oiy']='\033[0;103m'   # On High Intensity backgrounds Yellow
    ['oib']='\033[0;104m'   # On High Intensity backgrounds Blue
    ['oip']='\033[0;105m'   # On High Intensity backgrounds Purple
    ['oic']='\033[0;106m'   # On High Intensity backgrounds Cyan
    ['oiw']='\033[0;107m'   # On High Intensity backgrounds White
)


# python rich colors
# https://rich.readthedocs.io/en/stable/appendix/colors.html
# https://rich.readthedocs.io/en/stable/style.html
declare -A RPCOLOR=(
    ['n']='[default]'   # No Style
    ['bn']='[bold]'     # Bold

    # Regular Colors
    ['k']='[black]'     # Black
    ['r']='[red]'       # Red
    ['g']='[gree]'      # Green
    ['y']='[yellow]'    # Yellow
    ['b']='[blue]'      # Blue
    ['p']='[magenta]'   # Purple
    ['c']='[cyan]'      # Cyan
    ['w']='[white]'     # White

    # Bold
    ['bk']='[bold black]'   # Bold Black
    ['br']='[bold red]'     # Bold Red
    ['bg']='[bold green]'   # Bold Green
    ['by']='[bold yellow]'  # Bold Yellow
    ['bb']='[bold blue]'    # Bold Blue
    ['bp']='[bold magenta]' # Bold Purple
    ['bc']='[bold cyan]'    # Bold Cyan
    ['bw']='[bold white]'   # Bold White

    # Underline
    ['uk']='[underline black]'   # Underline Black
    ['ur']='[underline red]'     # Underline Red
    ['ug']='[underline green]'   # Underline Green
    ['uy']='[underline yellow]'  # Underline Yellow
    ['ub']='[underline blue]'    # Underline Blue
    ['up']='[underline magenta]' # Underline Purple
    ['uc']='[underline cyan]'    # Underline Cyan
    ['uw']='[underline white]'   # Underline White

    # On Background
    ['ok']='[on black]'     # On Background Black
    ['or']='[on red]'       # On Background Red
    ['og']='[on green]'     # On Background Green
    ['oy']='[on yellow]'    # On Background Yellow
    ['ob']='[on blue]'      # On Background Blue
    ['op']='[on magenta]'   # On Background Purple
    ['oc']='[on cyan]'      # On Background Cyan
    ['ow']='[on white]'     # On Background White

    # High Intensity
    ['ik']='[bright_black]'    # High Intensity Black
    ['ir']='[bright_red]'      # High Intensity Red
    ['ig']='[bright_green]'    # High Intensity Green
    ['iy']='[bright_yellow]'   # High Intensity Yellow
    ['ib']='[bright_blue]'     # High Intensity Blue
    ['ip']='[bright_magenta]'  # High Intensity Purple
    ['ic']='[bright_cyan]'     # High Intensity Cyan
    ['iw']='[bright_white]'    # High Intensity White

    # Bold High Intensity
    ['bik']='[bold bright_black]'   # Bold High Intensity Black
    ['bir']='[bold bright_red]'     # Bold High Intensity Red
    ['big']='[bold bright_green]'   # Bold High Intensity Green
    ['biy']='[bold bright_yellow]'  # Bold High Intensity Yellow
    ['bib']='[bold bright_blue]'    # Bold High Intensity Blue
    ['bip']='[bold bright_magenta]' # Bold High Intensity Purple
    ['bic']='[bold bright_cyan]'    # Bold High Intensity Cyan
    ['biw']='[bold bright_white]'   # Bold High Intensity White

    # On High Intensity backgrounds
    ['oik']='[on bright_black]'   # On High Intensity backgrounds Black
    ['oir']='[on bright_red]'     # On High Intensity backgrounds Red
    ['oig']='[on bright_green]'   # On High Intensity backgrounds Green
    ['oiy']='[on bright_yellow]'  # On High Intensity backgrounds Yellow
    ['oib']='[on bright_blue]'    # On High Intensity backgrounds Blue
    ['oip']='[on bright_magenta]' # On High Intensity backgrounds Purple
    ['oic']='[on bright_cyan]'    # On High Intensity backgrounds Cyan
    ['oiw']='[on bright_white]'   # On High Intensity backgrounds White

)


# ##############################################################################
# use color themes
# https://catppuccin.com/palette

declare -A HCOLOR=(
    # Regular Colors
    ['k']='#11111b'      # Black
    ['r']='#f38ba8'      # Red
    ['g']='#a6e3a1'      # Green
    ['y']='#f9e2af'      # Yellow
    ['b']='#89b4fa'      # Blue
    ['p']='#cba6f7'      # Purple
    ['c']='#89dceb'      # Cyan
    ['w']='#cdd6f4'      # White
)
