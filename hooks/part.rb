exit_reply "Better do that in one of my channels" unless $msg.sent_to_channel?
exit_reply "#{$args} is not a channel name" unless IRC::channel_name?($args)
raw "PART #{$args}"
