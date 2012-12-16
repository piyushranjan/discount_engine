class Discount

  attr_accessor :name, :discount_type, :condition_sets, :discount_value, :and_or

  def initialize(name, discount_type=:percentage, discount_value=0, and_or=:and)
    raise 'not a valid type' unless name.is_a?(String)
    raise 'not a valid type' unless discount_value.is_a?(Numeric) or discount_value.is_a?(Proc)
    raise 'not a valid type' unless discount_type.is_a?(Symbol)
    raise 'not a valid value' if not (discount_type==:percentage or discount_type==:value or discount_type==:formula)

    self.and_or   = (and_or || :and)
    self.name = name
    self.discount_type = discount_type
    self.discount_value = discount_value
    self.condition_sets = []
  end

  def add_condition_set(condition_set)
    self.condition_sets.push(condition_set)
  end

  def remove_condition_set(condition_set)
    self.condition_sets.delete(condition_set)
  end

  def applicable?(cart)
    evaluate(cart)
  end

  def get_amount(cart)
    return 0 unless applicable?(cart)

    discount =
    if discount_type == :percentage

      cart.bill_amount
      # this discount should get applicable for groceries

      non_grocery_bill = cart.items.find_all{|item|
        item.product.product_type.name != :grocery
      }.map{|item|
        item.product.value * item.quantity
      }.reduce(0){|s,x| s+=x}

      (non_grocery_bill * (discount_value.is_a?(Proc) ? discount_value.call(cart) : discount_value)/100.0)
    elsif discount_type == :value
      self.discount_value.is_a?(Proc) ? self.discount_value.call(cart) : self.discount_value
    end
  end

  def evaluate(obj)
    if(self.and_or == :and)
      self.condition_sets.map{|condition_set|
        condition_set.evaluate(obj)
      }.reduce{|s, x|
        s and x
      }
    elsif self.and_or == :or
      self.condition_sets.map{|condition_set|
        condition_set.evaluate(obj)
      }.reduce{|s, x|
        s or x
      }
    end
  end
end
