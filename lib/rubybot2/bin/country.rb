#!/usr/bin/env ruby

SYNTAX = 'Usage: !country <2-letter code> | <country name>'

CODES = [
    'ac', 'ad', 'ae', 'af', 'ag', 'ai', 'al', 'am', 'an', 'ao', 'aq', 'ar',
    'as', 'at', 'au', 'aw', 'az', 'ba', 'bb', 'bd', 'be', 'bf', 'bg', 'bh',
    'bi', 'bj', 'bm', 'bn', 'bo', 'br', 'bs', 'bt', 'bv', 'bw', 'by', 'bz',
    'ca', 'cc', 'cd', 'cf', 'cg', 'ch', 'ci', 'ck', 'cl', 'cm', 'cn', 'co',
    'cr', 'cu', 'cv', 'cx', 'cy', 'cz', 'de', 'dj', 'dk', 'dm', 'do', 'dz',
    'ec', 'ee', 'eg', 'eh', 'er', 'es', 'et', 'fi', 'fj', 'fk', 'fm', 'fo',
    'fr', 'ga', 'gd', 'ge', 'gf', 'gg', 'gh', 'gi', 'gl', 'gm', 'gn', 'gp',
    'gq', 'gr', 'gs', 'gt', 'gu', 'gw', 'gy', 'hk', 'hm', 'hn', 'hr', 'ht',
    'hu', 'id', 'ie', 'il', 'im', 'in', 'io', 'iq', 'ir', 'is', 'it', 'je',
    'jm', 'jo', 'jp', 'ke', 'kg', 'kh', 'ki', 'km', 'kn', 'kp', 'kr', 'kw',
    'ky', 'kz', 'la', 'lb', 'lc', 'li', 'lk', 'lr', 'ls', 'lt', 'lu', 'lv',
    'ly', 'ma', 'mc', 'md', 'mg', 'mh', 'mk', 'ml', 'mm', 'mn', 'mo', 'mp',
    'mq', 'mr', 'ms', 'mt', 'mu', 'mv', 'mw', 'mx', 'my', 'mz', 'na', 'nc',
    'ne', 'nf', 'ng', 'ni', 'nl', 'no', 'np', 'nr', 'nu', 'nz', 'om', 'pa',
    'pe', 'pf', 'pg', 'ph', 'pk', 'pl', 'pm', 'pn', 'pr', 'ps', 'pt', 'pw',
    'py', 'qa', 're', 'ro', 'ru', 'rw', 'sa', 'sb', 'sc', 'sd', 'se', 'sg',
    'sh', 'si', 'sj', 'sk', 'sl', 'sm', 'sn', 'so', 'sr', 'st', 'sv', 'sy',
    'sz', 'tc', 'td', 'tf', 'tg', 'th', 'tj', 'tk', 'tm', 'tn', 'to', 'tp',
    'tr', 'tt', 'tv', 'tw', 'tz', 'ua', 'ug', 'uk', 'um', 'us', 'uy', 'uz',
    'va', 'vc', 've', 'vg', 'vi', 'vn', 'vu', 'wf', 'ws', 'ye', 'yt', 'yu',
    'za', 'zm', 'zw'
]

COUNTRIES = [
    "Ascension Island", "Andorra", "United Arab Emirates", "Afghanistan",
    "Antigua and Barbuda", "Anguilla", "Albania", "Armenia",
    "Netherlands Antilles", "Angola", "Antarctica", "Argentina",
    "American Samoa", "Austria", "Australia", "Aruba", "Azerbaijan",
    "Bosnia and Herzegovina", "Barbados", "Bangladesh", "Belgium",
    "Burkina Faso", "Bulgaria", "Bahrain", "Burundi", "Benin", "Bermuda",
    "Brunei Darussalam", "Bolivia", "Brazil", "Bahamas", "Bhutan",
    "Bouvet Island", "Botswana", "Belarus", "Belize", "Canada",
    "Cocos (Keeling) Islands", "Congo, Democratic Republic of the",
    "Central African Republic", "Congo, Republic of", "Switzerland",
    "Cote d'Ivoire", "Cook Islands", "Chile", "Cameroon", "China", "Colombia",
    "Costa Rica", "Cuba", "Cap Verde", "Christmas Island", "Cyprus",
    "Czech Republic", "Germany", "Djibouti", "Denmark", "Dominica",
    "Dominican Republic", "Algeria", "Ecuador", "Estonia", "Egypt",
    "Western Sahara", "Eritrea", "Spain", "Ethiopia", "Finland", "Fiji",
    "Falkland Islands (Malvina)", "Micronesia, Federal State of",
    "Faroe Islands", "France", "Gabon", "Grenada", "Georgia", "French Guiana",
    "Guernsey", "Ghana", "Gibraltar", "Greenland", "Gambia", "Guinea",
    "Guadeloupe", "Equatorial Guinea", "Greece",
    "South Georgia and the South Sandwich Islands", "Guatemala", "Guam",
    "Guine", "Guyana", "Hong Kong", "Heard and McDonald Islands", "Honduras",
    "Croatia/Hrvatska", "Haiti", "Hungary", "Indonesia", "Ireland", "Israel",
    "Isle of Man", "India", "British Indian Ocean Territory", "Iraq",
    "Iran (Islamic Republic of)", "Iceland", "Italy", "Jersey", "Jamaica",
    "Jordan", "Japan", "Kenya", "Kyrgyzstan", "Cambodia", "Kiribati",
    "Comoros", "Saint Kitts and Nevis", "Korea, Democratic People's Republic",
    "Korea, Republic of", "Kuwait", "Cayman Islands", "Kazakhstan",
    "Lao People's Democratic Republic", "Lebanon", "Saint Lucia",
    "Liechtenstein", "Sri Lanka", "Liberia", "Lesotho", "Lithuania",
    "Luxembourg", "Latvia", "Libyan Arab Jamahiriya", "Morocco", "Monaco",
    "Moldova, Republic of", "Madagascar", "Marshall Islands",
    "Macedonia, Former Yugoslav Republic", "Mali", "Myanmar", "Mongolia",
    "Macau", "Northern Mariana Islands", "Martinique", "Mauritania",
    "Montserrat", "Malta", "Mauritius", "Maldives", "Malawi", "Mexico",
    "Malaysia", "Mozambique", "Namibia", "New Caledonia", "Niger",
    "Norfolk Island", "Nigeria", "Nicaragua", "Netherlands", "Norway", "Nepal",
    "Nauru", "Niue", "New Zealand", "Oman", "Panama", "Peru",
    "French Polynesia", "Papua New Guinea", "Philippines", "Pakistan",
    "Poland", "St. Pierre and Miquelon", "Pitcairn Island", "Puerto Rico",
    "Palestinian Territories", "Portugal", "Palau", "Paraguay", "Qatar",
    "Reunion Island", "Romania", "Russian Federation", "Rwanda", "Saudi Arabia",
    "Solomon Islands", "Seychelles", "Sudan", "Sweden", "Singapore",
    "St. Helena", "Slovenia", "Svalbard and Jan Mayen Islands",
    "Slovak Republic", "Sierra Leone", "San Marino", "Senegal", "Somalia",
    "Suriname", "Sao Tome and Principe", "El Salvador", "Syrian Arab Republic",
    "Swaziland", "Turks and Caicos Islands", "Chad",
    "French Southern Territories", "Togo", "Thailand", "Tajikistan", "Tokelau",
    "Turkmenistan", "Tunisia", "Tonga", "East Timor", "Turkey",
    "Trinidad and Tobago", "Tuvalu", "Taiwan", "Tanzania", "Ukraine", "Uganda",
    "United Kingdom", "US Minor Outlying Islands", "United States", "Uruguay",
    "Uzbekistan", "Holy See (City Vatican State)",
    "Saint Vincent and the Grenadines", "Venezuela", "Virgin Islands (British)",
    "Virgin Islands (USA)", "Vietnam", "Vanuatu", "Wallis and Futuna Islands",
    "Western Samoa", "Yemen", "Mayotte", "Yugoslavia", "South Africa", "Zambia",
    "Zimbabwe"
]

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" if args.length == 0

    code = args
    country = 'country not found'

    if args.length == 2
        i = CODES.index(args)
        country = COUNTRIES[i] if i
    else
        re = Regexp.new(args, Regexp::IGNORECASE)
        COUNTRIES.each_index { |i|
            if COUNTRIES[i] =~ re
                country = COUNTRIES[i]
                code = CODES[i]
                break
            end
        }
    end

    "P\t#{code} - #{country}"
end

load 'boilerplate.rb'
