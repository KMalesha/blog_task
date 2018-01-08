# frozen_string_literal: true

require 'spec_helper'

describe SelectAuthorsWithSameIp do
  context 'when posts do not exist' do
    it 'returns Right monad with successful message' do
      monad = SelectAuthorsWithSameIp.new.call({})

      expect(monad.right?).to be true
      expect(monad.value[:message]).to eq('OK')
    end

    it 'returns empty array in payload' do
      monad = SelectAuthorsWithSameIp.new.call({})

      expect(monad.value[:authors]).to eq([])
    end
  end

  context 'when posts exist' do
    before do
      Factory.create_post_with_author(login: 'John Doe', ip: '192.168.1.1')
      Factory.create_post_with_author(login: 'Samson Lui', ip: '192.168.1.1')
    end

    it 'returns Right monad with successful message' do
      monad = SelectAuthorsWithSameIp.new.call({})

      expect(monad.right?).to be true
      expect(monad.value[:message]).to eq('OK')
    end

    it 'returns empty array in payload' do
      monad = SelectAuthorsWithSameIp.new.call({})

      expect(monad.value[:authors]).to eq([ { ip: '192.168.1.1', logins: ['John Doe', 'Samson Lui'] } ])
    end
  end
end
