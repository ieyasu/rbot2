require 'socket'

begin
  m = match_args /(?:(\d+\.\d+\.\d+\.\d+)|(\S+))/, '<hostname> | <ip address>'
  ip,host = m[1],m[2]

  if ip
    addr = ip.split('.').map(&:to_i).pack('CCCC')
    ary = Socket::gethostbyaddr(addr)
    reply "#{ip} points to #{ary.first}"
  else
    ary = Socket::gethostbyname(host)
    ipaddr = ary[3].unpack('CCCC').join('.')
    reply "#{host} has address #{ipaddr}"
  end
rescue SocketError => e
    if e.message =~ / not (?:found|known)/i
        reply "host #{$args} not found"
    else
        raise e
    end
end
