require 'rubybot2/account'

accounts = DB[:accounts].select_col(:name)
reply(accounts.length > 0 ? "accounts: #{accounts.join(', ')}" :
      "there are no accounts in the system")
