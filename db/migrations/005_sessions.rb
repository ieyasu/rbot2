Sequel.migration do
  up do
    create_table(:sessions) do
      String :sid, :primary_key => true
      String :account
      Fixnum :expires_at
    end
  end

  down do
    drop_table :sessions
  end
end
