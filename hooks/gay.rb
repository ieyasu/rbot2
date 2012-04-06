def faghash(str)
    h = 0
    str.each_byte { |b| h = (h << 5) - h + b }
    ret = (h % 50) - ((h >> 8) % 50) + ((h >> 16) % 25) - ((h >> 24) % 26)
    ret = (ret * 49) % 100 if ret & 4 == 0
    ret *= 3 if ret ^ 0xFF >> 3 == 0
    ret *= 2 if ret >> 2 ^ 0xA == 0
    ret = -ret if ret < 0
    ret
end

match_args /\S+/, '<name>'
reply "#{$args} is #{faghash($args)}% gay"
