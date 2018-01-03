# frozen_string_literal: true

class RatePost
  include Dry::Transaction

  step :validate
  step :rate_post

  Schema = Dry::Validation.Form do
    required(:rating).schema do
      required(:post_id).filled(:int?)
      required(:rating).filled(:int?, included_in?: 1..5)
    end
  end

  def validate(input)
    result = Schema.call(input)
    if result.success?
      Right(result)
    else
      Left(status: 422, message: "Validation error", errors: result.errors)
    end
  end

  def rate_post(input)
    params = input[:rating]

    # update rating
    DB.transaction do
      current = DB[:posts].select(:id, :rating, :number_of_rating)
                                 .where(id: params[:post_id])
                                 .for_update
                                 .first
      if current
        new_rating = ((current[:rating].to_f * current[:number_of_rating] + params[:rating]) /
                     (current[:number_of_rating] + 1)).round(2)
        DB[:posts].where(id: current[:id])
                  .update(rating: new_rating, number_of_rating: current[:number_of_rating] + 1)
        Right(status: 200, message: "OK", rating: new_rating)
      else
        Left(status: 404, message: 'Post not found')
      end
    end
  end
end
