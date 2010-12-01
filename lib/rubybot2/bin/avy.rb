#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'open-uri'

# \002 bold
# \003 color (color,bg)
# \017 reset
# \026 reverse foreground and background
# \037 underline

IRC_COLORS = {
  :white =>       0,
  :black =>       1,
  :blue =>        2,
  :green =>       3,
  :red =>         4,
  :brown =>       5,
  :purple =>      6,
  :orange =>      7,
  :yellow =>      8,
  :light_green => 9,
  :cyan =>        10,
  :light_cyan =>  11,
  :light_blue =>  12,
  :pink =>        13,
  :grey =>        14,
  :light_grey =>  15
}

BACKGROUND_COLORS = { # from http://www.irssi.org/documentation/formats
  :black =>       1,
  :blue =>        2,
  :green =>       3,
  :red =>         5,
  :purple =>      6,
  :orange =>      7,
  :cyan =>        10,
  :light_grey =>  15
}

REGIONS = {
  'aspen' => 'http://avalanche.state.co.us/Forecasts/Aspen/',
  'front range' => 'http://avalanche.state.co.us/Forecasts/Front+Range/',
  'grand mesa' => 'http://avalanche.state.co.us/Forecasts/Grand+Mesa/',
  'gunnison' => 'http://avalanche.state.co.us/Forecasts/Gunnison/',
  'n san juan' => 'http://avalanche.state.co.us/Forecasts/N+San+Juan/',
  's san juan' => 'http://avalanche.state.co.us/Forecasts/S+San+Juan/',
  'sangre de cristo' => 'http://avalanche.state.co.us/Forecasts/Sangre+De+Cristo/',
  'sawatch range' => 'http://avalanche.state.co.us/Forecasts/Sawatch+Range/',
  'steamboat' => 'http://avalanche.state.co.us/Forecasts/Steamboat/',
  'vail & summit county' => 'http://avalanche.state.co.us/Forecasts/Vail+Summit+Co/'
}

def irc_color(color, text)
  foreground, background = [color,nil]
  if color.kind_of? Array
    if color.size.between?(1,2)
      foreground, background = color      
    else
      raise "invalid color code #{color.inspect}"
    end
  else
  end

  raise "color specification required" unless foreground
  [foreground,background].each {|c| raise "invalid color code #{c.inspect}" unless !c || IRC_COLORS[c] }

  "\003%d%s%s\017" % [ IRC_COLORS[foreground], background ? ',%d' % BACKGROUND_COLORS[background] : '', text]
end

WARNING_LEVELS = {
  /LOW/ => irc_color(:green, 'LOW'),
  /MODERATE|MODREATE/ => irc_color(:yellow, 'MODERATE'),
  /CONSIDERABLE/ => irc_color(:orange, 'CONSIDERABLE'),
  /HIGH/ => irc_color(:red, 'HIGH'),
  /EXTREME/ => irc_color([:black,:red],'EXTREME')
}

def handle_command(nick, dest, args)
    
  region = 'front range'
  unless args.empty?  
    if args == 'help'
    	return "P\t!avy [region] returns a listing of avalanche conditions for a given region, " +
        "defaulting to the front range. The following regions are available: " +
        "aspen, front range, grand mesa, gunnison, n san juan, s san juan, sangre de cristo, sawatch range, " +
        "steamboat, vail & summit county." +
        " See http://avalanche.state.co.us for more information"
      EOS
    else
      search = args.downcase
      found_region = REGIONS.keys.find {|r| r[args] }
      if found_region
        region = found_region
      else
        return "P\tcould not find region #{args}"
      end
    end
  end
  
	doc = Hpricot(open(REGIONS[region]))
	report = (doc/'span#ZoneDangerControl1_LabelDanger')
  if report
		report = (report/'p') unless report/'p'.empty?
		report = report.first if report.respond_to? :first
		report = report.inner_html.gsub(/<[^>]+>/,'').strip
		report = report.gsub(/&nbsp;|\n/,' ').gsub(/\s+/,' ')
		date = (doc/'span#ZoneWeatherForecastControl_LabelIssuer').inner_html
    date = date.match(/at: (.*) by/) && Regexp.last_match.captures.first || 'unknown'
		WARNING_LEVELS.each do |pattern,replacement|
		  report.gsub!(pattern,replacement)
		end
		"P\t%s: %s (%s)" % [region, report, date]
  else
    "P\terror scraping conditions"
  end

rescue Exception => e
  "P\terror: #{e}"
end

require 'boilerplate' 
