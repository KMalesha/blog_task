# frozen_string_literal: true

class SelectAuthorsWithSameIp
  include Dry::Transaction

  step :select_different_ips

  def select_different_ips(input)
    authors = DB[:posts].select(:ip, Sequel.function(:array_agg, :login).distinct.as(:logins))
                        .group(:ip)
                        .having{ Sequel.function(:count, :author_id).distinct > 1 }
                        .all
    Right(status: 200, message: 'OK', authors: authors)
  end
end
