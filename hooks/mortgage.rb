m = match_args(/(\d+(?:\.\d+)?)\s+(\d+(?:\.\d+)?)%?\s+(\d+)(?:\s+(\d+(?:\.\d+)?))?/,
      '<principle> <rate%> <number of years> [downpayment]   Example: !mortgage 230000 5.5 30')
_,p,r,n,d = m.to_a.map(&:to_f)

p -= d
r = (r / 1200.0)
r = r.round(5)
n = n * 12.0

a = ((p * (1 + r) ** n) * r) / ((1 + r) ** n - 1)

reply "Monthly payment: $#{a.round(2)}"
