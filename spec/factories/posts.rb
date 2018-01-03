# frozen_string_literal: true

class Factory
  def self.create_post(opts = {})
    DB.transaction do
      DB[:posts].insert(title: opts[:title] || 'Title',
                          body: opts[:body] || 'Content',
                          ip: opts[:ip] || '192.168.1.1',
                          rating: opts[:rating] || '5.0')
    end
  end
end
