# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:authors) do
      primary_key :id
      String :login, null: false
    end
  end
end
