return {
    descriptions = {
        Back = {
            b_jjok_gojodeck = {name = 'Gojo Deck',
                    text = {'The deck of the {C:jjok_lblue}Gojo{} clan,',
                        'start with a {C:spectral}Soul{} and',
                        '{C:jjok_special}Awaken{}, {C:red}-2{} Joker slots'}},
            b_jjok_zenindeck = {name = "Zen'in Deck",
                    text = {"The deck of the Zen'in clan,",
                            'start with a random', 
                            '{C:jjok_jjk}Jujutsu Joker'}}
        },
        Enhanced = {
            m_jjok_lucky_hak = {name = 'Lucky Card',
                                text = {
                                    '{C:green}Guaranteed{} to give',
                                    '{C:mult}+20{} Mult and {C:money}$20{} Dollars'
                                }}
        },
        Other = {
            jjok_electric_seal = {name = 'Conductive Seal',
                text = { 'After scoring, this seal gains',
            '{C:attention}#1#{} charge when played',
            '{C:inactive}(Currently {C:jjok_lblue}#2#{C:inactive} Charges)',
            '{C:jjok_lblue}1{} Charge:',
            '{C:attention,s:0.8}1{C:inactive,s:0.8} Retrigger',
            '{C:jjok_lblue}2{} Charges:',
            '{C:attention,s:0.8}2{C:inactive,s:0.8} Retriggers, {C:white,X:chips,s:0.8}X1.5{C:inactive,s:0.8} Chips when scored',
            '{C:jjok_lblue}3{} Charges:',
            '{C:attention,s:0.8}3{C:inactive,s:0.8} Retriggers, {C:white,X:chips,s:0.8}X2{C:inactive,s:0.8} Chips when scored',
            '{C:inactive,s:0.8}(self destructs)' }},

            jjok_slots = {text = {{'Requires {C:attention}#1#{} Slots'}}},
            jjok_ce_cost = {text = {{'Costs {C:dark_edition}#1#{} Cursed Energy'}}},
        }
    },
    misc = {
        dictionary={
            k_common="Grade 4",
            k_uncommon="Grade 3",
            k_rare="Grade 2",
            k_legendary="Grade 1",

            b_rarities = 'Rarities',
            b_roll = 'Roll!',

            jjok_tac = 'Art by Tacashumi'
        },
        labels = {
            jjok_electric_seal = 'Conductive Seal'
        }
    }
}
