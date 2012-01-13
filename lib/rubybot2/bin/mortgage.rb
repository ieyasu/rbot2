#!/usr/bin/env ruby

USAGE = "P\tUsage: !mortgage <principle> <rate%> <number of years> [downpayment].  Example: !mortgage 230000 5.5 30"

def handle_command(nick, dest, args)
  ary = args.split
  return USAGE unless ary.length >= 3
  p,r,n,d = ary.map {|a| a.to_f}

  d = 0.0 unless d

  p -= d
  r = (r / 1200.0)
  r = r.round(5)
  n = n * 12.0

  a = ((p * (1 + r) ** n) * r) / ((1 + r) ** n - 1)

  "P\tMonthly payment: $#{a.round(2)}"
end

load 'boilerplate.rb'
