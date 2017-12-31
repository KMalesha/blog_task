# frozen_string_literal: true

class Factory
  def self.create_author(name = 'John Doe')
    DB.transaction do
      DB[:authors].insert(login: name)
    end
  end
end
