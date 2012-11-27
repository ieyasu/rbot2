require 'digest/md5'
reply "MD5 of '#{$args}' == #{Digest::MD5.hexdigest($args)}"
