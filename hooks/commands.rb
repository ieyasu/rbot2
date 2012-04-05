INTERNAL = ["accounts", "addnick", "at", "deletelastnext", "delnick", "forget",
            "help", "in", "listnexts", "login", "logout", "mremember", "next",
            "nicks", "pastnexts", "raw", "read", "register", "remember",
            "seen", "setpass", "setzip", "unregister", "whatis"]

reply (INTERNAL + (Dir.entries('bin') - ['.', '..'])).sort.join(', ')
