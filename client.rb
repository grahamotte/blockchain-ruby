require 'json'
require 'rest-client'
require 'set'
require 'pp'
require 'openssl'
require 'base64'
require 'tty-table'

require_relative 'txn'
require_relative 'block'
require_relative 'origin_block'

origin_key = OpenSSL::PKey::RSA.new(OriginBlock.new.private_key)
other_keys = Dir['test_keys/*'].map { |kf| OpenSSL::PKey::RSA.new(File.read(kf)) }

def post_transaction(from:, to:, amount: rand(100))
  timestamp = Time.now.to_i
  from_public = from.public_key.export
  to_public = to.public_key.export
  message = Digest::SHA256.hexdigest([timestamp, amount, from_public, to_public].join)
  signature = Base64.encode64(from.private_encrypt(message))

  params = {
    from: from_public,
    to: to_public,
    amount: amount,
    signature: signature,
    timestamp: timestamp
  }

  RestClient.post('http://localhost:1234/send', params)
end


loop do
  # spread the wealth
  other_keys.sample(5).each do |k|
    post_transaction(from: origin_key, to: k)
  end

  # cheat the system
  3.times do
    from, to = other_keys.sample(2)
    post_transaction(from: from, to: to)
  end

  sleep 5
end

