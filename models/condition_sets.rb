class ConditionSet
  attr_accessor :discount, :conditions, :and_or

  def initialize(and_or=:and)
    and_or =  nil unless [:and, :or].include?(and_or)
    self.and_or   = and_or
    self.conditions = []
  end

  def add_condition(condition)
    self.conditions.push(condition)
  end

  def delete_condition(condition)
    self.conditions.delete(condition)
  end

  def evaluate(obj)
    if(self.and_or == :and)
      self.conditions.map{|condition|
        condition.evaluate(obj)
      }.reduce{|s, x|
        s and x
      }
    elsif self.and_or == :or
      self.conditions.map{|condition|
        condition.evaluate(obj)
      }.reduce{|s, x|
        s or x
      }
    end
  end
end
