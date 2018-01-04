# frozen_string_literal: true

require 'spec_helper'
require_relative '../factories/authors'

describe CreatePost do
  let(:params) do
    {
      post: {
        title: 'Title',
        body: 'Content',
        author: 'Simon Pegg',
        ip: '192.166.1.1'
      }
    }
  end

  context 'when params is invalid:' do
    context 'title is not present' do
      before { params[:post].delete(:title) }

      it 'return Left monad with validation errors' do
        monad = CreatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(post: { title: ['is missing'] } )
      end
    end

    context 'title has an invalid length' do
      before { params[:post][:title] = "a" * 251 }

      it 'return Left monad with validation errors' do
        monad = CreatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(post: { title: ['length must be within 5 - 250'] } )
      end
    end

    context 'body is empty' do
      before { params[:post].delete(:body) }

      it 'return Left monad with validation errors' do
        monad = CreatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(post: { body: ['is missing'] } )
      end
    end

    context 'author is empty' do
      before { params[:post].delete(:author) }

      it 'return Left monad with validation errors' do
        monad = CreatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(post: { author: ['is missing'] } )
      end
    end

    context 'ip is invalid' do
      before { params[:post][:ip] = "something wrong" }

      it 'return Left monad with validation errors' do
        monad = CreatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(post: { ip: ['is in invalid format'] } )
      end
    end
  end

  context 'when params is valid' do
    context 'and author exists in db' do
      before do
        Factory.create_author("Bob Kelso")
        params[:post][:author] = "Bob Kelso"
      end

      it 'return Right monad with successful message' do
        monad = CreatePost.new.call(params)

        expect(monad.right?).to be true
        expect(monad.value[:message]).to eq("OK")
      end

      it 'does not create new author' do
        expect { CreatePost.new.call(params) }.to_not change{ DB[:authors].count }
      end

      it 'create new post' do
        expect { CreatePost.new.call(params) }.to change{ DB[:posts].count }.by(1)
        expect(DB[:posts].first).to include(title: params[:post][:title],
                                            body: params[:post][:body],
                                            ip: params[:post][:ip],
                                            login: params[:post][:author],
                                            rating: nil)
      end
    end

    context 'and author does not exist in db' do
      it 'return Right monad with successful message' do
        monad = CreatePost.new.call(params)

        expect(monad.right?).to be true
        expect(monad.value[:message]).to eq("OK")
      end

      it 'create new author' do
        expect { CreatePost.new.call(params) }.to change{ DB[:authors].count }.by(1)
      end

      it 'create new post' do
        expect { CreatePost.new.call(params) }.to change{ DB[:posts].count }.by(1)
        expect(DB[:posts].first).to include(title: params[:post][:title],
                                            body: params[:post][:body],
                                            ip: params[:post][:ip],
                                            login: params[:post][:author],
                                            rating: nil)
      end
    end
  end
end
