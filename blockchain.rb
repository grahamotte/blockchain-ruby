class Blockchain
  attr_reader :chain, :latest

  def initialize(chain: { OriginBlock.new.block_hash => OriginBlock.new })
    @chain = chain
    @latest = chain.values.last
  end

  def sync_from_serialized(blockchain:, latest_block_hash:)
    their_pos = latest_block_hash
    their_blocks = {}

    # find last agreed upon block
    blockchain.length.times do
      their_block = Block.new_from_serialized(blockchain[their_pos])
      return false unless their_block.valid?
      their_blocks[their_pos] = their_block
      break if @chain[their_pos]
      their_pos = their_block.previous_block_hash
    end

    divergence_pos = their_pos

    # can't do anything if we have nothing in common
    return false unless divergence_pos
    their_join_block = their_blocks[divergence_pos]
    our_join_block = @chain[divergence_pos]
    return false unless their_join_block.to_json == our_join_block.to_json

    # collect branches
    their_branch = their_blocks
    our_branch = chain_from(@chain[divergence_pos])

    # take their branch only if it is longer than ours
    return false if our_branch.length >= their_branch.length

    # drop our branch
    our_branch.each { |k, _| @chain.delete(k) }

    # add in theirs
    their_branch.each { |k, v| @chain[k] = v }
    @latest = @chain[latest_block_hash]
  end

  def chain_from(past, present = @latest)
    pos = @latest.block_hash

    blocks = {
      present.block_hash => present,
      past.block_hash => past
    }

    while pos != past.block_hash
      blocks[present.block_hash] = present
      pos = blocks[pos].previous_block_hash
    end

    blocks
  end

  def last(n)
    pos = @latest.block_hash
    items = []

    n.times do
      current_block = @chain[pos]
      if current_block
        items << current_block
        pos = current_block.previous_block_hash
      else
        return items
      end
    end

    items
  end

  def add(block)
    valid = true
    valid &&= block.valid?
    valid &&= @latest.block_hash == block.previous_block_hash
    valid &&= balances(with: block).values.all?(&:positive?)

    if valid
      @chain[block.block_hash] = block
      @latest = block
      true
    else
      false
    end
  end

  def valid?
    valid = true
    valid &&= @chain.values.all? { |b| b.valid? }

    pos = @latest.block_hash

    (@chain.length - 1).times do
      pos = @chain[pos].previous_block_hash
    end

    valid &&= pos == OriginBlock.new.block_hash
  end

  def all_txn_messages
    @chain
      .values
      .map(&:txns)
      .flatten
      .map(&:message)
  end

  def balances(with: nil)
    balances = {}

    (@chain.values + [with].compact).each do |block|
      block.txns.each do |t|
        balances[t.from] = 0 unless balances.key?(t.from)
        balances[t.to] = 0 unless balances.key?(t.to)

        balances[t.from] -= t.amount
        balances[t.to] += t.amount
      end
    end

    balances.delete(OriginBlock.new.block_hash)
    balances
  end

  # interface

  def serialize
    {
      blockchain: @chain.map { |k, v| [k, v.serialize] }.to_h,
      latest_block_hash: @latest.block_hash,
    }
  end

  def recent_blocks_to_s(n: 5)
    puts "chain valid => #{valid?}"
    last(n).each { |b| b.to_s }.join("\n")
  end

  def balances_to_s
    def name(id)
      id.split("\n")[1].last(8) rescue id
    end

    TTY::Table
      .new(rows: balances.map { |k, v| [name(k), v] })
      .render(:unicode, multiline: true, padding: [0, 1, 0, 1], alignments: [:left, :right])
  end
end