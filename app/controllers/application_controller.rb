class ApplicationController < ActionController::API
  def create_post
    CreatePost.new.call(params) do |m|
      m.success do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
      m.failure do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
    end
  end

  def rate_post
    RatePost.new.call(params) do |m|
      m.success do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
      m.failure do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
    end
  end

  def top_posts
    SelectTopPosts.new.call(params) do |m|
      m.success do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
      m.failure do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
    end
  end

  def authors_with_same_ip
    SelectAuthorsWithSameIp.new.call(params) do |m|
      m.success do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
      m.failure do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
    end
  end

  def rate_random_posts
    RateRandomPosts.new.call(params) do |m|
      m.success do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
      m.failure do |output|
        render status: output.delete(:status), body: Oj.dump(output), content_type: 'application/json'
      end
    end
  end

  private def params
    request.parameters
  end
end
