class Product
  attr_accessor :code, :name, :value, :product_type

  def initialize(code, name, value, product_type)
    raise CannotBeBlank unless code
    raise CannotBeBlank unless value
    raise CannotBeBlank unless product_type
    raise NotAValidType unless value.is_a?(Numeric)
    raise NotAValidType unless code.is_a?(String)
    raise NotAValidType unless product_type.is_a?(ProductType)
    raise NotCorrectVal if value<=0

    self.code  = code
    self.value = value
    self.name  = name
    self.product_type = product_type
  end
end
