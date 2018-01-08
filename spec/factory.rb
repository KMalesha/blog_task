# frozen_string_literal: true

class Factory
  def self.create_author(params = {})
    DB.transaction do
      author = DB[:authors].returning
                           .insert(login: params[:login] || 'John Doe')
                           .first
    end
  end

  def self.create_post(opts = {})
    DB.transaction do
      DB[:posts].returning
                .insert(title: opts[:title] || 'Title',
                        body: opts[:body] || 'Content',
                        ip: opts[:ip] || '192.168.1.1',
                        rating: opts[:rating],
                        number_of_rating: opts[:number_of_rating] || 0,
                        login: opts[:author] || 'John Doe' )
                .first
    end
  end

  def self.create_post_with_author(opts = {})
    DB.transaction do
      author_id = DB[:authors].insert(login: opts[:login] || 'John Doe')

      DB[:posts].returning
                .insert(title: opts[:title] || 'Title',
                        body: opts[:body] || 'Content',
                        ip: opts[:ip] || '192.168.1.1',
                        rating: opts[:rating] || '5.0',
                        login: opts[:login] || 'John Doe',
                        author_id: author_id)
                .first
    end
  end
end
