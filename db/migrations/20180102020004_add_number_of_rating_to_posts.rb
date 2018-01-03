# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:posts) do
      add_column :number_of_rating, Integer, default: 0
    end
  end
end
