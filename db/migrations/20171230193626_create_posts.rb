# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:posts) do
      primary_key :id
      foreign_key :author_id, :authors
      String :title, null: false
      String :body, text: true, null: false
      String :ip, size: 15
      Float :rating

      index :author_id, type: 'btree'
    end
  end
end
