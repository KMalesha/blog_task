# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:posts) do
      add_column :login, String
      add_index :ip, type: 'btree'
    end
  end
end
