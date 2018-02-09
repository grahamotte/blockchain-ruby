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
require_relative 'blockchain'

$origin_key = OpenSSL::PKey::RSA.new(OriginBlock.new.private_key)
$other_keys = Dir['test_keys/*'].map { |kf| OpenSSL::PKey::RSA.new(File.read(kf)) }

def generate_txn(from:, to:, amount: rand(1000))
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

  Txn.new(**params.map { |k, v| [k.to_sym, v] }.to_h)
end

def add_new_block(blockchain, amount: 25)
  txns = (0..1).map { generate_txn(from: $origin_key, to: $other_keys.first, amount: amount) }
  block = Block.new(previous_block_hash: blockchain.latest.block_hash, txns: txns)
  block.find_valid_nonce
  blockchain.add(block)
end

$blockchain_1 = Blockchain.new
$blockchain_2 = Blockchain.new
add_new_block($blockchain_1, amount: 25)
add_new_block($blockchain_2, amount: 25)
puts $blockchain_1.recent_blocks_to_s

puts '########'

add_new_block($blockchain_2, amount: 50)
puts $blockchain_2.recent_blocks_to_s

$blockchain_1.sync_from_serialized($blockchain_2.serialize)

puts '########'

puts $blockchain_1.recent_blocks_to_s

# --  send txns --
# def post_transaction(from:, to:, amount: rand(100))
#   timestamp = Time.now.to_i
#   from_public = from.public_key.export
#   to_public = to.public_key.export
#   message = Digest::SHA256.hexdigest([timestamp, amount, from_public, to_public].join)
#   signature = Base64.encode64(from.private_encrypt(message))
#
#   params = {
#     from: from_public,
#     to: to_public,
#     amount: amount,
#     signature: signature,
#     timestamp: timestamp
#   }
#
#   RestClient.post('http://localhost:1234/send', params)
# end
#
# loop do
#   # spread the wealth
#   other_keys.sample(5).each do |k|
#     post_transaction(from: origin_key, to: k)
#   end
#
#   # cheat the system
#   3.times do
#     from, to = other_keys.sample(2)
#     post_transaction(from: from, to: to)
#   end
#
#   sleep 5
# end
#
