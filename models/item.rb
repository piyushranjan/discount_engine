class Item
  attr_accessor :product, :quantity

  def initialize(product, quantity)
    raise 'cannot be blank' unless product
    raise 'cannot be blank' unless quantity
    raise 'not a valid type' unless  product.is_a?(Product)
    raise 'not a valid type' unless  quantity.is_a?(Numeric)
    raise 'incorrect value' if quantity<=0

    self.product = product
    self.quantity = quantity
  end
end


