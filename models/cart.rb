class Cart
  attr_accessor :items, :user, :store, :applied_discounts
  attr_reader :bill_amount, :discount_amount

  def initialize(user, store)
    self.user = user
    self.store = store
    self.items = []
    self.applied_discounts = []
  end

  def add_item(product, quantity)
    if item = self.items.find{|i| i.product == product}
      item.quantity+= quantity
    else
      self.items.push(Item.new(product, quantity))
    end
  end

  def remove_item(product)
    self.items = self.items.reject{|item| item.product == product}
  end

  def items_count
    self.items.length
  end

  def bill_amount
    self.calculate_bill_amount
  end

  def discount_amount
    self.calculate_discount_amount
  end

  def final_payable
    self.bill_amount - self.discount_amount
  end

  def calculate_bill_amount
    bill_amount =
      items.map{|item|
      item.product.value * item.quantity
    }.reduce(0){|s,x|
      s+=x
    }
  end

  def applicable_discounts
    self.store.discounts.find_all{|discount|
      discount.applicable?(self)
    }
  end

  def calculate_discount_amount
    discounts = {:percentage => [], :value => []}

    applicable_discounts.map{|discount|
      discounts[discount.discount_type].push(discount.get_amount(self))
    }
    discount_amount = (discounts[:percentage].max||0) + (discounts[:value].reduce(0){|s,x| s+=x}||0)
  end

  def to_s
    self.items.map{|item|
      "#{item.product.code}\t#{item.product.name}\t\t#{item.product.value}\t#{item.quantity}\t#{item.product.value * item.quantity}"
    }
  end
end
