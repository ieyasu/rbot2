CREATE TABLE last (
    nick      TEXT NOT NULL,
    chan      TEXT NOT NULL,
    stmt      TEXT NOT NULL,
    at        INT  NOT NULL,
    PRIMARY KEY (nick, chan)
);

CREATE INDEX last_at ON last (at);

CREATE TABLE accounts (
    name   TEXT NOT NULL,
    zip    INT,
    passwd TEXT,
    email  TEXT,
    -- could add col here for notified
    PRIMARY KEY (name)
);

CREATE TABLE nick_accounts (
    nick    TEXT NOT NULL,
    account TEXT NOT NULL,
    authed  INT  NOT NULL DEFAULT 0,
    PRIMARY KEY (nick)
);

CREATE TABLE nexts (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    sent_at      INT  NOT NULL,
    from_nick    TEXT NOT NULL,
    from_account TEXT,
    message      TEXT NOT NULL
);

CREATE INDEX nexts_sent_at ON nexts (sent_at);

CREATE TABLE account_recips (
    next_id      INT  NOT NULL,
    account      TEXT NOT NULL,
    other_recips TEXT NOT NULL,  -- always present, may be ""
    PRIMARY KEY (next_id, account)
);

CREATE INDEX account_recips_account ON account_recips (account);

CREATE TABLE pattern_recips (
    next_id      INT  NOT NULL,
    nick_pat     TEXT NOT NULL,
    other_recips TEXT NOT NULL,  -- always present, may be ""
    PRIMARY KEY (next_id, nick_pat)
);

CREATE TABLE received_nexts (
    account  TEXT NOT NULL,
    sent_at  INT  NOT NULL,
    recvd_at INT  NOT NULL,
    message  TEXT NOT NULL,
    PRIMARY KEY (recvd_at, message)
);

CREATE INDEX received_nexts_account ON received_nexts (account);
CREATE INDEX received_nexts_recvd_at ON received_nexts (recvd_at);

CREATE TABLE whatis (
	thekey TEXT NOT NULL,
	value  TEXT NOT NULL,
	nick   TEXT,
	PRIMARY KEY (thekey)
);

CREATE TABLE cron (
    at      INT  NOT NULL,
    nick    TEXT NOT NULL,
    chan    TEXT NOT NULL,
    message TEXT NOT NULL,
    PRIMARY KEY (at, nick, message)
);

CREATE INDEX cron_at ON cron (at);
