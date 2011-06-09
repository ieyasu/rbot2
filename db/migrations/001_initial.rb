Sequel.migration do
  up do
    create_table(:last) do
      String :nick
      String :chan
      String :stmt, :size => 512
      Fixnum :at, :index => true
      primary_key [:nick, :chan]
    end

    create_table(:accounts) do
      String :name, :primary_key => true
      Fixnum :zip
      String :passwd
    end

    create_table(:nick_accounts) do
      String :nick, :null => false, :primary_key => true
      String :account, :null => false
    end

    create_table(:nexts) do
      primary_key :id
      Fixnum :sent_at, :null => false, :index => true
      String :from_nick, :null => false
      String :from_account
      String :message, :null => false, :size => 512
    end

    create_table(:account_recips) do
      Fixnum :next_id, :null => false
      String :account, :null => false, :index => true
      String :other_recips, :null => false
      primary_key [:next_id, :account]
    end

    create_table(:pattern_recips) do
      Fixnum :next_id, :null => false
      String :nick_pat, :null => false
      String :other_recips, :null => false
      primary_key [:next_id, :nick_pat]
    end

    create_table(:received_nexts) do
      String :account, :null => false, :index => true
      Fixnum :sent_at, :null => false
      Fixnum :recvd_at, :null => false, :index => true
      String :message, :null => false, :size => 512
      primary_key [:recvd_at, :message]
    end

    create_table(:whatis) do
      String :thekey, :primary_key => true
      String :value, :null => false, :size => 512
      String :nick
    end

    create_table(:cron) do
      Fixnum :at, :null => false, :index => true
      String :nick, :null => false
      String :chan, :null => false
      String :message, :null => false, :size => 512
      primary_key [:at, :nick, :message]
    end
  end

  down do
    drop_table :last
    drop_table :accounts
    drop_table :nick_accounts
    drop_table :nexts
    drop_table :account_recips
    drop_table :pattern_recips
    drop_table :received_nexts
    drop_table :whatis
    drop_table :cron
  end
end
