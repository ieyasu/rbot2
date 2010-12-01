#!/usr/bin/env ruby

if File.directory?('/home/rubybot/lib') # production
  $:.unshift '/home/rubybot/lib/activeresource/lib'
  $:.unshift '/home/rubybot/lib/activesupport/lib'
else
  $:.unshift 'activeresource/lib'
  $:.unshift 'activesupport/lib'
end

require 'active_support'
require 'active_resource'

class Resort < ActiveResource::Base
  self.site = 'http://snow.otherward.net'  
end

class LatestReport < ActiveResource::Base
  # dummy resource, this is used by Resort when building the latest report object
end

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

POWDER_DAY = 5 # inches

def irc_color(color, text)
  raise "invalid color code" unless IRC_COLORS[color]
  "\003#{IRC_COLORS[color]}#{text}\017"
end

def handle_command(nick, dest, args)
  resorts = Resort.find(:all)
    
  if args == 'help'
    return "P\t !snow returns a listing of snow conditions at various resorts. usage: !snow [ resort name | help ]"
  end
  
  if args.size > 0
    specific = args.downcase
    resorts = resorts.find_all {|resort| resort.nickname[specific]}
  end
  
  if resorts.empty?
    "P\tresort #{args} not found, but it's probably snowing there."
  else
    "P\t" + resorts.map do |resort|
      if resort.attributes.has_key?('latest_report')
        report = "#{resort.nickname} #{resort.latest_report.formatted_conditions}"
        if resort.latest_report.base == 0 || !resort.latest_report.base # nil
          irc_color(:red, report)
        elsif resort.latest_report.updated_at < 1.day.ago
          irc_color(:yellow, report)
        elsif resort.latest_report.snow24 && resort.latest_report.snow24 >= POWDER_DAY
          irc_color(:green, report)
        else
          report
        end
      else # no latest report, something is wrong
        irc_color(:red, "#{resort.nickname} (n/a)")
      end
    end.join(', ')
  end

rescue SystemCallError, ActiveResource::ServerError => e
  "P\terror: #{e.to_s} - but it's snowing somewhere"
end

require 'boilerplate' # this calls "handle_command" based on the command-line args this script was called with.
