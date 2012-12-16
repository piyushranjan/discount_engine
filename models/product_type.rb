class ProductType
  attr_accessor :name

  def initialize(name)
    raise NameCannotBeBlank if name.empty?
    self.name = name.to_sym
  end
end
