# Written by Nathan Witmer

ONE = %w(collection dominion enclave estates harbor haven hearth homes homestead manor plantation preserve 
	quarters refuge reserve residences resort retreat sanctuary summit village).map {|w| w.capitalize}.freeze
TWO = %w(antelope beacon buffalo coyote eagle elk harvest hawk horizon mountain panorama pine prairie
  river saddle shadow silver sky spring thunder wolf).map {|w| w.capitalize}.freeze
THREE = %w(bluff branch brook canyon cliff creek crest edge falls gate glen haven lake lane peak rock shire
  tree valley view wood).map {|w| w.capitalize}.freeze
FOUR = %w(commons court cove crossing farms gardens heights highlands hills junction knoll landing meadows
  park place point ranch ridge run trails vista).map {|w| w.capitalize}.freeze

reply "the newest denver subdivision is: The #{r ONE} at #{r TWO} #{r THREE} #{r FOUR}"
