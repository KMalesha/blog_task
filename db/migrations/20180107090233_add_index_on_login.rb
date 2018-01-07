# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:authors) do
      add_index(:login)
    end
  end
end
