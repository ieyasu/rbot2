require 'wolfram'

Wolfram.appid = "L6LWRQ-5JY85G3LQ5"
r = Wolfram::HashPresenter.new(Wolfram.fetch($args)).to_hash

# deal with WA's various pod types
if r[:pods]['Result'] and r[:pods]['Input interpretation'] then
  reply("Result: #{r[:pods]['Result'].first} (Interpreted input: #{r[:pods]['Input interpretation'].first})")
elsif r[:pods]['Decimal approximation']
  reply("Result: #{r[:pods]['Decimal approximation'].first}")
elsif r[:pods]['Exact result']
  reply("Result: #{r[:pods]['Exact result'].first}")
elsif r[:pods]['Result']
  reply("Result: #{r[:pods]['Result'].first}")
elsif r[:pods]['Results']
  reply("Result: #{r[:pods]['Results'].first}")
else
  reply("THERE ARE FOUR LIGHTS")
end
