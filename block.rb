class Block
  attr_reader :previous_block_hash, :txns, :nonce

  def initialize(previous_block_hash:, txns:, nonce: nil)
    @previous_block_hash = previous_block_hash
    @txns = txns
    @nonce = nonce
  end

  def self.new_from_serialized(serialized)
    Block.new(
      previous_block_hash: serialized[:previous_block_hash],
      txns: serialized[:txns].map { |tj| Txn.new(**tj) },
      nonce: serialized[:nonce]
    )
  end

  def block_hash
    Digest::SHA256.hexdigest(to_json)
  end

  def valid?
    valid = true

    valid &&= block_hash.start_with?('00')
    valid &&= txns.all?(&:valid?)
    valid &&= txns.length > 0
    valid &&= txns.length <= 10

    valid
  end

  def find_valid_nonce
    @nonce = 'Thy kiss is comfortless as frozen water to a starved snake'
    @nonce = nonce.next until valid?
    @nonce
  end

  # interface

  def to_json
    serialize.to_json
  end

  def to_hash
    {
      previous_block_hash: previous_block_hash,
      txns: txns,
      nonce: @nonce
    }
  end

  def serialize
    {
      previous_block_hash: previous_block_hash,
      txns: txns.map(&:serialize),
      nonce: @nonce
    }
  end

  def to_s
    TTY::Table.new(
      rows: {
        block_hash: block_hash,
        nonce: nonce,
        valid: valid?,
        txns: txns.map(&:to_s).join("\n"),
        previous_block_hash: previous_block_hash,
      }.to_a
    ).render(:unicode, multiline: true, padding: [0, 1, 0, 1])
  end
end
