# frozen_string_literal: true

require 'spec_helper'

describe 'API', type: :request do
  let(:headers) do
    {
      'ACCEPT' => 'application/json',
      'HTTP_ACCEPT' => 'application/json',
      'CONTENT_TYPE' => 'application/json'
    }
  end

  describe 'create_post' do
    subject(:post_request) { post '/posts/create', Oj.dump(params), headers }

    context 'when params is invalid' do
      let(:params) do
        {
          post: {
            title: 'Title',
            body: 'Content',
            ip: '192.168.1.1'
          }
        }
      end

      it 'receives response with validation error' do
        post_request
        body = Oj.load(resp.body)

        expect(resp.status).to eq(422)
        expect(body['message']).to eq('Validation error')
      end
    end

    context 'when params is valid' do
      let(:params) do
        {
          post: {
            author: 'John Doe',
            title: 'Title',
            body: 'Content',
            ip: '192.168.1.1'
          }
        }
      end

      context 'and author exists' do
        before { Factory.create_author(ligin: params[:post][:author]) }

        it 'receives successfully response' do
          post_request
          body = Oj.load(resp.body)

          expect(resp.status).to eq(201)
          expect(body['message']).to eq('OK')
        end

        it 'does not create new author' do
          expect { post_request }.to_not change{ DB[:authors].count }
        end

        it 'create new post' do
          expect { post_request }.to change{ DB[:posts].count }.by(1)
          expect(DB[:posts].first).to include(title: params[:post][:title],
                                              body: params[:post][:body],
                                              ip: params[:post][:ip],
                                              login: params[:post][:author],
                                              rating: nil)
        end
      end

      context 'and author does not exist' do
        it 'receives successfully response' do
          post_request
          body = Oj.load(resp.body)

          expect(resp.status).to eq(201)
          expect(body['message']).to eq('OK')
        end

        it 'create new author' do
          expect { post_request }.to change{ DB[:authors].count }.by(1)
        end

        it 'create new post' do
          expect { post_request }.to change{ DB[:posts].count }.by(1)
          expect(DB[:posts].first).to include(title: params[:post][:title],
                                              body: params[:post][:body],
                                              ip: params[:post][:ip],
                                              login: params[:post][:author],
                                              rating: nil)
        end
      end
    end
  end

  describe 'rate_post' do
    let(:_post) { Factory.create_post }

    subject(:post_request) { post '/posts/rate', Oj.dump(params), headers }

    context 'when params is invalid' do
      let(:params) do
        {
          rating: { post_id: _post[:id] }
        }
      end

      it 'receives response with validation error' do
        post_request
        body = Oj.load(resp.body)

        expect(resp.status).to eq(422)
        expect(body['message']).to eq('Validation error')
      end
    end

    context 'when params is valid' do
      let(:params) do
        {
          rating: {
            post_id: _post[:id],
            rating: 4 }
        }
      end

      it 'receives successfully response' do
        post_request
        body = Oj.load(resp.body)

        expect(resp.status).to eq(200)
        expect(body['message']).to eq('OK')
        expect(body['rating']).to eq(4.5)
      end

      it 'update rating correctly' do
        post_request

        expect(DB[:posts].where(id: _post[:id]).first[:rating]).to eq((_post[:rating] + params[:rating][:rating]) / 2.0)
        expect(DB[:posts].where(id: _post[:id]).first[:number_of_rating]).to eq(2)
      end
    end
  end

  describe 'select_top_posts' do
    subject(:get_request) { get '/posts/top', params , headers }

    before do
      5.times do |i|
        Factory.create_post(title: "top_#{i + 1}", rating: (5 - i).to_f)
      end
    end

    context 'when params is invalid' do
      let(:params) { {} }

      it 'receives response with validation error' do
        get_request
        body = Oj.load(resp.body)

        expect(resp.status).to eq(422)
        expect(body['message']).to eq('Validation error')
      end
    end

    context 'when params is valid' do
      let(:params) { { top_n: 3 } }

      it 'receives successfully response' do
        get_request
        body = Oj.load(resp.body)

        expect(resp.status).to eq(200)
        expect(body['message']).to eq("Top #{params[:top_n]} posts")
        expect(body['posts']).to be_present
      end

      it 'returns top 3 posts' do
        get_request
        body = Oj.load(resp.body)

        expect(body['posts'].count).to eq(3)
        expect(body['posts']).to eq(Array.new(3) { |i| { 'title' => "top_#{i + 1}", 'body' => 'Content' } })
      end
    end
  end

  describe 'select_authors_with_same_ip' do
    subject(:get_request) { get '/authors/with_same_ip', nil , headers }

    before do
      Factory.create_post_with_author(login: 'Daniel Keyes', ip: '192.168.1.1')
      Factory.create_post_with_author(login: 'Neal Stephenson', ip: '192.168.1.1')
      Factory.create_post_with_author(login: 'Daniel Keyes', ip: '10.10.0.1')
      Factory.create_post_with_author(login: 'Neal Stephenson', ip: '10.10.0.1')
      Factory.create_post_with_author(login: 'Eliezer Yudkowsky', ip: '10.10.0.1')
      Factory.create_post_with_author(login: 'David Wong', ip: '127.0.0.1')
    end

    it 'receives successfully response' do
      get_request
      body = Oj.load(resp.body)

      expect(resp.status).to eq(200)
      expect(body['message']).to eq('OK')
      expect(body['authors']).to match_array([ { 'ip' => '192.168.1.1',
                                                 'logins' => match_array(['Daniel Keyes', 'Neal Stephenson']) },
                                               { 'ip' => '10.10.0.1',
                                                 'logins' => match_array(['Daniel Keyes', 'Neal Stephenson', 'Eliezer Yudkowsky']) } ])
    end
  end
end
