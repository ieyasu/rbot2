INSERT INTO accounts VALUES('account', 80521, '6680bbec89e8:77ccceddf0f2c15b7fd13814dedfcef1', 'account@example.com');
INSERT INTO accounts VALUES('account2', 80524, '618888f6659:8fc6af18e3dbc4e31e2509975f2cf85e', NULL);

INSERT INTO nick_accounts VALUES('nick', 'account', 1);
INSERT INTO nick_accounts VALUES('unauthnick', 'account', 0);

INSERT INTO received_nexts VALUES('account',1168727913, 1168727992, 'nick (account): <from> a message');
INSERT INTO received_nexts VALUES('account',1168727923, 1168728002, 'nick (account): <from> a message 1');
INSERT INTO received_nexts VALUES('account',1168727933, 1168728012, 'nick (account): <from> a message 2');
INSERT INTO received_nexts VALUES('account',1168727943, 1168728022, 'nick (account): <from> a message 3');

INSERT INTO nexts VALUES(NULL,1168758290,'nick','account','msg1');
INSERT INTO nexts VALUES(NULL,1168758291,'frm2',NULL,'msg2');
INSERT INTO nexts VALUES(NULL,1168758292,'frm3',NULL,'msg3');
INSERT INTO nexts VALUES(NULL,1168758293,'frm4',NULL,'msg4');
INSERT INTO nexts VALUES(NULL,1168758294,'frm5',NULL,'msg5');
INSERT INTO nexts VALUES(NULL,1168758295,'frm6',NULL,'msg6');

INSERT INTO account_recips VALUES(2, 'account', '');
INSERT INTO account_recips VALUES(3, 'account', '');

INSERT INTO pattern_recips VALUES(1, 'tonick', '');
INSERT INTO pattern_recips VALUES(4, 'foo', 'bar');
INSERT INTO pattern_recips VALUES(5, 'ba', '');
INSERT INTO pattern_recips VALUES(6, 'ar', '');

INSERT INTO whatis VALUES('foo','bar','person');
