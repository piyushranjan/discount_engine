class Condition
  attr_accessor :key, :predicate, :value

  def initialize(key, predicate, value)
    self.key = key
    self.predicate = predicate
    self.value = value
  end

  def evaluate(obj)
    lhs =
      if self.key.is_a?(Proc)
        self.key.call(obj)
      else
        self.key
      end
    mhs = get_comparator(predicate)
    rhs = self.value.is_a?(Proc) ? self.value.call : self.value
    lhs.send(mhs, rhs)
  end

  private
  def get_comparator(predicate)
    case predicate
    when :equal
      :==
    when :less_than
      :<
    when :less_than_equal
      :<=
    when :greater_than
      :>
    when :greater_than_equal
      :>=
    when :not
        :!=
    end
  end
end
