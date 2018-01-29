class Blockchain
  attr_reader :chain, :latest

  def initialize(chain: { OriginBlock.new.block_hash => OriginBlock.new })
    @chain = chain
    @latest = chain.values.last
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

  def add(**block_params)
    block = Block.new(**block_params)

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

  def balances_to_s
    def name(id)
      id.split("\n")[1].last(8) rescue id
    end

    TTY::Table
      .new(rows: balances.map { |k, v| [name(k),  v] })
      .render(:unicode, multiline: true, padding: [0, 1, 0, 1], alignments: [:left, :right])
  end
end