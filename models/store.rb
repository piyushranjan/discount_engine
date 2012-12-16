class Store
  attr_accessor :name, :products, :discounts, :product_types

  def initialize(name)
    self.name
    self.products  = []
    self.discounts = []
    self.product_types = []
  end

  def add_product_type(product_type)
    raise NotAValidType unless product_type.is_a?(ProductType)
    self.product_types.push(product_type)
  end

  def remove_product_type(product_type)
    raise NotAValidType unless product_type.is_a?(ProductType)
    self.product_types.delete(product_type)
  end

  def add_product(product)
    raise NotAValidType unless product.is_a?(Product)
    self.products.push(product)
  end

  def find_product(product_code)
    self.products.find{|product| product.code == product_code}
  end

  def remove_product(product)
    raise NotAValidType unless product.is_a?(Product)
    self.products.delete(product)
  end

  def add_discount(discount)
    raise NotAValidType unless discount.is_a?(Discount)
    self.discounts.push(discount)
  end

  def remove_discount(discount)
    raise NotAValidType unless discount.is_a?(Discount)
    self.discounts.delete(discount)
  end

  def remove_product_type(discount)
    raise NotAValidType unless discount.is_a?(Discount)
    self.discounts.delete(discount)
  end

end
