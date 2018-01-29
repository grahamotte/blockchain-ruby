class TxnPool < ThreadSafe::Array

  def add_many_serialized(txns)
    (txns || []).each { |st| add_serialized(**st.map { |k, v| [k.to_sym, v] }.to_h) }
  end

  def add_serialized(**txn_params)
    txn = Txn.new(**txn_params.map { |k, v| [k.to_sym, v] }.to_h)
    if txn.valid?
      push(txn.serialize)
      uniq!
      true
    else
      false
    end
  end

  def remove_txn(txn)
    delete(txn.serialize)
  end

  def all_txns
    map { |st| Txn.new(**st) }
  end

  def clean(balances, verified_txn_messages)
    uniq!

    all_txns
      .select { |t| (balances[t.from] || 0) < t.amount }
      .each { |t| remove_txn(t) }

    all_txns
      .select { |t| verified_txn_messages.include?(t.message) }
      .each { |t| remove_txn(t) }
  end

# helpers

  def to_json
    serialize.to_json
  end

  def serialize
    self
  end
end
