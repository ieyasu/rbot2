Sequel.migration do
  up do
    add_column :levels, :account, String
    self[:levels].each do |lev|
      na = self[:nick_accounts].filter(:nick => lev[:nick]).first
      a = self[:accounts].filter(:name => na[:account]) if na
      account = a.first[:name] if a
      if account
        q = self[:levels].filter(:nick => lev[:nick])
        q.update(:account => account, :nick => nil)
      end
    end
  end

  down do
    drop_column :levels, :account
  end
end
