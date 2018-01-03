#  frozen_string_literal: true

class SelectTopPosts
  include Dry::Transaction

  step :validate
  step :select_top_posts

  Schema = Dry::Validation.Form do
    required(:top_n).filled(:int?, gt?: 0)
  end

  def validate(input)
    result = Schema.call(input)
    if result.success?
      Right(result.output)
    else
      Left(status: 422, message: 'Validation error', errors: result.errors)
    end
  end

  def select_top_posts(input)
    top_posts = nil
    DB.transaction do
      top_posts = DB[:posts].select(:title, :body)
                            .order(Sequel.desc(:rating))
                            .first(input[:top_n])
    end
    Right(status: 201, message: "Top #{input[:top_n]} posts", posts: top_posts)
  end
end
