# frozen_string_literal: true

require 'spec_helper'

describe RatePost do
  let(:post) { Factory.create_post(rating: nil, number_of_rating: 0) }
  let(:params) do
    {
      rating: {
        post_id: post[:id],
        rating: 5
      }
    }
  end

  context 'when params is invalid:' do
    context 'post_id is not preset' do
      before { params[:rating].delete(:post_id) }

      it 'return Left monad with validation errors' do
        monad = RatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(rating: { post_id: ['is missing'] } )
      end
    end

    context 'rating is not present' do
      before { params[:rating].delete(:rating) }

      it 'return Left monad with validation errors' do
        monad = RatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(rating: { rating: ['is missing'] } )
      end
    end

    context 'rating is not a number' do
      before { params[:rating][:rating] = 'fdasf' }

      it 'return Left monad with validation errors' do
        monad = RatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(rating: { rating: ['must be an integer'] } )
      end
    end

    context 'rating is not a integer' do
      before { params[:rating][:rating] = '1.34' }

      it 'return Left monad with validation errors' do
        monad = RatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(rating: { rating: ['must be an integer'] } )
      end
    end

    context 'rating out of range' do
      before { params[:rating][:rating] = '6' }

      it 'return Left monad with validation errors' do
        monad = RatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(422)
        expect(monad.value[:message]).to eq('Validation error')
        expect(monad.value[:errors]).to eq(rating: { rating: ['must be one of: 1 - 5'] } )
      end
    end

    context 'post do not exist' do
      before { params[:rating][:post_id] += 1 }

      it 'return Left monad with validation errors' do
        monad = RatePost.new.call(params)

        expect(monad.left?).to be true
        expect(monad.value[:status]).to eq(404)
        expect(monad.value[:message]).to eq('Post not found')
      end
    end
  end

  context 'when params is valid' do
    context 'when number_of_rating is 0' do
      it 'return Right monad and update rating correctly' do
        monad = RatePost.new.call(params)

        expect(monad.right?).to be true
        expect(monad.value[:message]).to eq('OK')
        expect(monad.value[:rating]).to eq(5.0)
        expect(DB[:posts].where(id: post[:id]).first[:rating]).to eq(5.0)
        expect(DB[:posts].where(id: post[:id]).first[:number_of_rating]).to eq(1)
      end
    end

    context 'when number_of_rating more than 0' do
      before do
        DB[:posts].where(id: post[:id]).update(rating: 14 / 3.0, number_of_rating: 3)
      end

      it 'return Right monad and update rating correctly' do
        monad = RatePost.new.call(params)

        expect(monad.right?).to be true
        expect(monad.value[:message]).to eq('OK')
        expect(monad.value[:rating]).to eq((19 / 4.0).round(2))
        expect(DB[:posts].where(id: post[:id]).first[:rating]).to eq(19 / 4.0)
        expect(DB[:posts].where(id: post[:id]).first[:number_of_rating]).to eq(4)
      end
    end
  end
end
