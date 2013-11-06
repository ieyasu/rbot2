require 'wolfram'

Wolfram.appid = "L6LWRQ-5JY85G3LQ5"
r = Wolfram::HashPresenter.new(Wolfram.fetch($args)).to_hash
if r[:pods]['Result'] then
  reply("Result: #{r[:pods]['Result'].first} (Interpreted input: #{r[:pods]['Input interpretation'].first})")
else
  reply("THERE ARE FOUR LIGHTS")
end
