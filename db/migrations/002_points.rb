Sequel.migration do
  up do
    create_table(:points) do
      String :thing, :primary_key => true
      Fixnum :points
    end
  end

  down do
    drop_table :points
  end
end
