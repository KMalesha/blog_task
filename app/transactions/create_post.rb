# frozen_string_literal: true

class CreatePost
  include Dry::Transaction

  step :validate
  step :create_author_and_post

  Schema = Dry::Validation.Form do
    required(:post).schema do
      required(:author).filled(:str?, size?: 5..250)
      required(:title).filled(:str?, size?: 5..250)
      required(:body).filled(:str?)
      required(:ip).filled(:str?, format?: /^([0-9]{1,3}\.){3}[0-9]{1,3}$/)
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

  def create_author_and_post(input)
    post = input[:post]
    author_id = nil

    # find or create author
    DB.transaction do
      author = DB[:authors].select(:id, :login)
                           .where(login: post[:author])
                           .first

      author_id = author ? author[:id] : DB[:authors].insert(login: post[:author])
    end

    # create post
    DB.transaction do
      DB[:posts].insert(author_id: author_id,
                        title: post[:title],
                        body: post[:body],
                        ip: post[:ip])
    end

    Right(status: 200, message: "OK")
  end
end
