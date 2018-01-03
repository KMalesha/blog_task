# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:posts) do
      add_index(:rating, opclass: "DESC NULLS LAST")
    end
  end
end
