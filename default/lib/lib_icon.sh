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
        # ['CRIT']=-2     # CRITICAL
        # ['ERRO']=-1     # ERROR
        # ['WARN']=0      # WARNING
        # ['NOTE']=1      # NOTICE
        # ['INFO']=2      # INFO
        # ['DEBG']=3      # DEBUG
        # ['FAIL']=-1     # FAIL
        # ['CHGD']=0      # CHANGED
        # ['OKAY']=1      # OKAY
        # ['SKIP']=2      # SKIP

    # check if nerdfonts is enabled
    if [[ $NERD -eq 1 ]]; then
        # colours
        declare -A id=(
            ['crit']='󰞏 '
            ['erro']=' '
            ['warn']=' '
            ['note']=' '
            ['info']=' '
            ['debg']='󰚩 '

            ['time']=' '
            ['unlock']=' '
            ['vpn']='󰕥 '
            ['vpn_warn']='󰳈 '
            ['vpn_crit']='󰻍 '
            ['net_crit']='󰅛 '
            ['dns_crit']='󰱟 '
            ['dns_warn']='󰲚 '
        )
    else
        # colours
        declare -A id=(
            ['crit']='🚨'
            ['erro']='❌'
            ['warn']='⚠️ '
            ['note']='✅'
            ['info']='ℹ️ '
            ['debg']='🤖'

            ['time']='🕐'
            ['unlock']='🔓'
            ['vpn']='🛡️'
            ['vpn_warn']='🗡️'
            ['vpn_crit']='⚔️ '
            ['net_crit']='🦍'
            ['dns_crit']='🐒'
            ['dns_warn']='🦥'
        )
    fi

    printf '%s' "${id[$1]}"
}
