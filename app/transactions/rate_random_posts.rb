# frozen_string_literal: true

class RateRandomPosts
  include Dry::Transaction

  step :rate_posts


  def rate_posts(input)
    DB.transaction do
      count = DB[:posts].select(Sequel.function(:count, :id))
                          .first[:count]
      posts = DB[:posts].select(:id)
                           .order(Sequel.function(:random))
                           .first((count * 0.05).to_i)

      posts.each do |post|
        params = { rating: {
                     post_id: post[:id],
                     rating: rand(1.0..5.0)
                   } }
        RatePost.new.call(params) do |m|
          m.success {}
          m.failure {}
        end
      end
      Right(status: 200, message: 'OK')
    end
  end
end
