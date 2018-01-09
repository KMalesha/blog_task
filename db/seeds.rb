# frozen_string_literal: true

Oj.default_options = {
  mode: :compat
}

require 'etc'
require 'ffaker'
require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

SERVER_URL = 'http://localhost:3000'
TITLE = 2..8 # words
PARAGRAPH = 5..10 # paragraphs
SENTENCE = 15..30 # sentences
NPROCESS = case Etc.nprocessors
          when 1 then 1
          when 2...4 then 2
          when 4...8 then 4
          else 8
          end
NPARALLELREQUEST = 20

NROWS = 200_000

conn = Faraday.new(url: SERVER_URL) do |conn|
  conn.adapter :typhoeus
end


begin
  conn.get
rescue Faraday::ConnectionFailed
  puts "#{SERVER_URL} unreachable"
end


authors = Array.new(100) { FFaker::Name.name }
ips = Array.new(50) { FFaker::Internet.ip_v4_address }

require 'benchmark'

puts Benchmark.measure {
  NPROCESS.times do
    fork do
      posts = Array.new(NROWS / NPROCESS) do
        Oj.dump(
          post: {
            author: authors.sample,
            title: FFaker::Lorem.words(rand(TITLE)).join(' '),
            body: Array.new(rand(PARAGRAPH)) { FFaker::Lorem.paragraph(rand(SENTENCE)) }.join("\n"),
            ip: ips.sample
          }
        )
      end
      (NROWS / NPROCESS / NPARALLELREQUEST).times do |i|
        conn.in_parallel do
          NPARALLELREQUEST.times do |j|
            conn.post do |req|
              req.url '/posts/create'
              req.headers['Content-Type'] = 'application/json'
              req.body = posts[i * NPARALLELREQUEST + j]
            end
          end
        end
      end
    end
  end
  Process.waitall
  conn.get do |req|
    req.url '/posts/rate_random'
    req.headers['Content-Type'] = 'application/json'
  end
}
