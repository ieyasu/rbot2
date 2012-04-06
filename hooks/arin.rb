require 'socket'

def arin_lookup(args)
    sock = TCPSocket.open('whois.arin.net', 43)
    sock.puts args
    infos = {}
    while (line = sock.gets)
        case line
        when /^OrgName:\s*(.+)/
            infos[:org] = $1
        when /^NetRange:\s*(.+)/
            infos[:range] = $1
        when /^NameServer:\s*(.+)/
            (infos[:ns] ||= []) << $1.downcase
        end
    end
    sock.close
    infos
end

match_args /\S+/, '<ip address range>'
if (infos = arin_lookup($args)) && infos[:range]
  s = "#{infos[:range]}: #{infos[:org]}"
  s << " (NS #{infos[:ns].join(', ')})" if infos[:ns]
  reply s
else
  reply "No match for '#{$args}'"
end
