require 'sinatra'
require 'sinatra/strong-params'
require 'active_support'
require 'active_support/core_ext'
require 'json'
require 'rest-client'
require 'set'
require 'pp'
require 'tty-table'
require_relative 'peer_pool'
require_relative 'txn_pool'
require_relative 'txn'
require_relative 'block'
require_relative 'origin_block'
require_relative 'blockchain'

disable :logging

hash_argv = ARGV
  .each_slice(2)
  .map { |k, v| [k.gsub('-', '').to_sym, v] }
  .to_h

$peer_pool = PeerPool.new(hash_argv[:peers]&.split(',') || [])
$txn_pool = TxnPool.new
$blockchain = Blockchain.new
$address = "http://localhost:#{hash_argv[:port]}"
$peer_pool.update($address)
set(:port, hash_argv[:port])
Thread.abort_on_exception = true

def fixed_line_zip(one, two)
  one = one.split("\n")
  two = two.split("\n")

  (0..[one.length, two.length].max).map do |i|
    one_part = i >= one.length ? ' ' * one.first.length : one[i]
    two_part = i >= two.length ? ' ' * two.first.length : two[i]

    "#{one_part} #{two_part}"
  end.join("\n")
end

# monitor
Thread.new do
  loop do
    sleep 2
    system 'clear'
    puts "peer pool - #{$peer_pool.length} - #{$peer_pool.to_a}"
    puts "txn pool  - #{$txn_pool.length} - #{$txn_pool.all_txns.map(&:to_s)}"
    puts fixed_line_zip($blockchain.last(3).map { |b| b.to_s }.join("\n"), $blockchain.balances_to_s)
    # $blockchain.balances_to_s
    # $blockchain.last(2).each { |b| puts b.to_s }
  end
end

# miner
if hash_argv[:miner]
  Thread.new do
    loop do
      if $txn_pool.any?
        current_balances = $blockchain.balances
        txn_set = $txn_pool.all_txns.sample(10)

        block = Block.new(previous_block_hash: $blockchain.latest.block_hash, txns: txn_set)
        block.find_valid_nonce

        if $blockchain.add(**block.to_hash)
          block.txns.each { |t| $txn_pool.remove_txn(t) }
        end
      end

      sleep 5
    end
  end
end

# node
Thread.new do
  loop do
    # sync with other nodes
    $peer_pool.each do |peer|
      next if peer == $address

      begin
        peers = JSON.parse(RestClient.post(peer + '/peer_pool', { peer_pool: $peer_pool }))
        txns = JSON.parse(RestClient.post(peer + '/txn_pool', { txn_pool: $txn_pool }))
        $peer_pool.update(peers['peer_pool'])

        $txn_pool.add_many_serialized(txns['txn_pool'])
      rescue => e
        $peer_pool.remove(peer)
        puts e
      end
    end

    # clean txn pool
    $txn_pool.clean($blockchain.balances, $blockchain.all_txn_messages)

    sleep 2
  end
end

post '/send', needs: [:timestamp, :from, :to, :amount, :signature], allows: [:timestamp, :from, :to, :amount, :signature] do
  content_type :json

  $txn_pool.add_serialized(
    from: params['from'],
    to: params['to'],
    amount: params['amount'].to_f,
    signature: params['signature'],
    timestamp: params['timestamp'],
  )
end

post '/peer_pool', allows: [:peer_pool] do
  content_type :json
  $peer_pool.update(params['peer_pool'])
  { peer_pool: $peer_pool }.to_json
end

post '/txn_pool', allows: [:txn_pool] do
  content_type :json

  $txn_pool.add_many_serialized(params['txn_pool'])
  $txn_pool.clean($blockchain.balances, $blockchain.all_txn_messages)

  { txn_pool: $txn_pool }.to_json
end

get '/blockchain', allows: [:blockchain] do
  content_type :json


end
