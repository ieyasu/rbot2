raw "MODE #{$msg.dest} -o #{$msg.nick}" if $msg.sent_to_channel?
