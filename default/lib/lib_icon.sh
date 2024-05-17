# ##############################################################################
#                                 FILE INFO
# icons
# ##############################################################################

# ##############################################################################
# Constants - global config
NERD=1 # default to use nerdfonts

# ##############################################################################
# gets the icon from the id
#
# Args:
#     [1]: (str) id of the icon
function icon() {

        # [-2]='👿'        # 🆘💥👾🛐👿🚨
        # [-1]='❌'        #
        # [0]='🔔'         # ⚠️✋👉🎃😬
        # [1]='✅'         #
        # [2]='ℹ️ '        #
        # [3]='🤖'         # 👽👻💀🪰🕷️

    # check if nerdfonts is enabled
    if [[ $NERD -eq 1 ]]; then
        # colours
        declare -A id=(
            ['crit']='󰞏'
            ['warn']=''
        )
    else
        # colours
        declare -A id=(
            ['crit']='🚨'
            ['warn']='⚠️'
        )
    fi

    printf '%s' "${id[$1]}"
}
