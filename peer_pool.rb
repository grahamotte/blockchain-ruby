class PeerPool < ThreadSafe::Array
  def update(items)
    return unless items
    items = [items] unless items.is_a?(Array)
    items.each { |i| push(block_given? ? yield(i) : i) }
    uniq!
  end

  def remove(items)
    return unless items
    items = [items] unless items.is_a?(Array)
    items.each { |i| delete(i) }
  end

  # interface

  def to_json
    to_a.to_json
  end

  def to_s
    to_a.to_s
  end
end
