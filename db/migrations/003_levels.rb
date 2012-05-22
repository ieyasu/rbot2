Sequel.migration do
  up do
    create_table(:levels) do
      String :nick, :primary_key => true
      String :level
    end
  end

  down do
    drop_table :levels
  end
end
