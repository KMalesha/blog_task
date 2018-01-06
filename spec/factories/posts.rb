# frozen_string_literal: true

class Factory
  def self.create_post(opts = {})
    DB.transaction do
      id = DB[:posts].insert(title: opts[:title] || 'Title',
                             body: opts[:body] || 'Content',
                             ip: opts[:ip] || '192.168.1.1',
                             rating: opts[:rating] || '5.0',
                             number_of_rating: opts[:number_of_rating] || 1,
                             login: opts[:author] || 'John Doe' )
      DB[:posts].where(id: id).first
    end
  end

  def self.create_post_with_author(opts = {})
    DB.transaction do
      author_id = DB[:authors].insert(login: opts[:login] || 'John Doe')

      id = DB[:posts].insert(title: opts[:title] || 'Title',
                             body: opts[:body] || 'Content',
                             ip: opts[:ip] || '192.168.1.1',
                             rating: opts[:rating] || '5.0',
                             login: opts[:login] || 'John Doe',
                             author_id: author_id)
      DB[:posts].where(id: id).first
    end
  end
end
