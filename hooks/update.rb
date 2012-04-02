#!/usr/bin/env ruby

SYNTAX = 'Usage: !update'

def check_reload
  if Dir['run/*.pid'].any? { |pid|
      service = pid.gsub(/run\/(.*)\.pid/, "services/\\1.rb")
      File.exist?(service) && File.mtime(service) > File.mtime(pid)
    }
    Process.kill('HUP', File.read('run/rubybot.pid').to_i)
    "P\t*** Reloaded services\n"
  else
    ''
  end
end

def handle_command(nick, dest, args)
  git = `git pull origin HEAD`
  out = ''
  git.each_line { |line| out << "P\t#{line.strip}\n" }
  out << check_reload
  out
end

load 'boilerplate.rb'
