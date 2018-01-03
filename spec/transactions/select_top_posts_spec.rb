# frozen_string_literal: true

require 'spec_helper'
require_relative '../factories/posts'

describe SelectTopPosts do
  let(:params) do
    { top_n: 3 }
  end

  context 'when params is invalid:' do
    context 'top_n is not present' do
      before { params.delete(:top_n) }

      it 'return Left monad with validation errors' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(top_n: ['is missing'])
      end
    end

    context 'top_n is not a number' do
      before { params[:top_n] = "sfdsadf" }

      it 'return Left monad with validation errors' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(top_n: ['must be an integer'])
      end
    end

    context 'top_n is not an integer' do
      before { params[:top_n] = "12.03" }

      it 'return Left monad with validation errors' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(top_n: ['must be an integer'])
      end
    end

    context 'top_n is zero' do
      before { params[:top_n] = "0" }

      it 'return Left monad with validation errors' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(top_n: ['must be greater than 0'])
      end
    end

    context 'top_n less than 0' do
      before { params[:top_n] = '-10' }

      it 'return Left monad with validation errors' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(top_n: ['must be greater than 0'])
      end
    end
  end

  context 'when params is valid' do
    context 'and posts do not exist' do
      it 'returns Right monad with successful message' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.right?).to be true
        expect(monad.value[:message]).to eq("Top #{params[:top_n]} posts")
      end

      it 'returns empty array' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.value[:posts].count).to eq(0)
        expect(monad.value[:posts]).to eq([])
      end
    end

    context 'and posts exist' do
      before do
        5.times do |i|
          Factory.create_post(title: "top_#{i + 1}", rating: (5 - i).to_f)
        end
      end

      it 'returns Right monad with successful message' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.right?).to be true
        expect(monad.value[:message]).to eq("Top #{params[:top_n]} posts")
      end

      it 'returns top 3 posts' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.value[:posts].count).to eq(3)
        expect(monad.value[:posts]).to eq(Array.new(3) { |i| { title: "top_#{i + 1}", body: 'Content' } })
      end
    end

    context 'and N more than posts count' do
      before do
        params[:top_n] = 10
        5.times do |i|
          Factory.create_post(title: "top_#{i + 1}", rating: (5 - i).to_f)
        end
      end

      it 'returns Right monad with successful message' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.right?).to be true
        expect(monad.value[:message]).to eq("Top #{params[:top_n]} posts")
      end

      it 'returns all posts' do
        monad = SelectTopPosts.new.call(params)

        expect(monad.value[:posts].count).to eq(5)
        expect(monad.value[:posts]).to eq(Array.new(5) { |i| { title: "top_#{i + 1}", body: 'Content' } })
      end
    end
  end
end
