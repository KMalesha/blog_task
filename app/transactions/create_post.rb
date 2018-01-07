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

    DB.transaction do
      author = DB[:authors].select(:id)
                           .where(login: post[:author])
                           .first

      author_id = author ? author[:id] : DB[:authors].insert(login: post[:author])

      DB[:posts].insert(author_id: author_id,
                        title: post[:title],
                        body: post[:body],
                        ip: post[:ip],
                        login: post[:author])
    end

    Right(status: 201, message: "OK")
  end
end
