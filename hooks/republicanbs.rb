# Ripped from http://www.duh.org/bullshit.html
P_VERBS = [
    'bring back', 'defend', 'elevate', 'empower', 'encourage', 'engage',
    'enshrine', 'enshroud', 'facilitate', 'fast-track', 'foster', 'give back',
    'help', 'instill', 'invest in', 'pro-growth', 'promote', 'protect',
    'push for', 'revive', 'share', 'stimulate', 'support' ]
P_ADJECTIVES = [
    'American', 'bipartisan', 'community', 'compassionate', 'conservative',
    'conventional', 'corporate', 'faith-based', 'family', 'heroic', 'homeland',
    'humanitarian', 'Iraqi', 'military', 'moral', 'patriotic', 'personal',
    'race-neutral', 'Reagan-era', 'traditional', 'upstanding' ]
P_NOUNS = [
    'agendas', 'aid', 'business', 'campaign contributions', 'economics',
    'education', 'freedom', 'funding', 'growth', 'heritage', 'initiatives',
    'integrity', 'involvement', 'justice', 'opportunity', 'peace', 'readiness',
    'responsibility', 'sanctity', 'security', 'strength', 'tax cuts', 'unity',
    'values' ]
N_VERBS = [
    'block', 'cut back', 'change', 'deflect', 'eliminate', 'eradicate',
    'expose', 'investigate', 'monitor', 'oppose', 'police', 'prevent',
    'reduce', 'remove', 'replace', 'smoke out', 'stem', 'stop', 'weed out' ]
N_ADJECTIVES = [
    'anti-American', 'biased', 'Clinton-era', 'Democratic', 'domestic',
    'foreign', 'French', 'Franco-American', 'liberal', 'malicious',
    'oppressive', 'partisan', 'radical', 'socialist', 'special interest',
    'treasonous', 'un-American', 'unpatriotic' ]
N_NOUNS = [
    'agendas', 'attacks', 'big government', 'deception', 'divisiveness',
    'enemies', 'entitlements', 'evildoers', 'handouts', 'influence',
    'insecurity', 'legislation', 'pandering', 'regimes', 'rhetoric',
    'special rights', 'spending', 'tactics', 'taxes', 'terrorism', 'threats',
    'welfare', 'wrongdoing' ]

phrase = (rand < 0.5) ? "#{r N_VERBS} #{r N_ADJECTIVES} #{r N_NOUNS}" :
                        "#{r P_VERBS} #{r P_ADJECTIVES} #{r P_NOUNS}"
reply "Republican Bullshit: #{phrase}"
