class Ocd::ValueCache
  attr_reader :value

  def initialize(value = nil)
    @value = value
  end

  def update(new_value)
    old_value = @value
    @value = new_value
    @updated = old_value != @value
  end

  def updated?
    !!@updated
  end
end
