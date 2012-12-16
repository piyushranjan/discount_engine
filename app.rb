require "bundler/setup"
Bundler.require(:default)
Dir["models/*.rb"].each do |file|
  load file
end


store = Store.new("Acme General Store")
baby_product = ProductType.new("baby_product")
store.add_product_type(baby_product)
store.add_product(Product.new("B01", "Johnson's baby oil", 100, baby_product))
store.add_product(Product.new("B02", "Johnson's baby powder", 250, baby_product))

grocery = ProductType.new("grocery")
store.add_product_type(grocery)
store.add_product(Product.new("G01", "Flour", 10, grocery))
store.add_product(Product.new("G02", "Pulses", 20, grocery))
store.add_product(Product.new("G03", "Rice", 20, grocery))
store.add_product(Product.new("G04", "Milk", 50, grocery))
store.add_product(Product.new("G05", "Gram", 30, grocery))
store.add_product(Product.new("G06", "Tea", 1, grocery))

beauty = ProductType.new("beauty")
store.add_product_type(beauty)
store.add_product(Product.new("E01", "Shampoo", 100, beauty))
store.add_product(Product.new("E02", "Soap", 20, beauty))
store.add_product(Product.new("E03", "Deaodrant", 200, beauty))
store.add_product(Product.new("E04", "Hair oil", 50, beauty))


d1 = Discount.new("Employee discount", :percentage, 30)
cd1 = ConditionSet.new(:and)
cd1.add_condition(Condition.new(Proc.new{|cart| cart.user.user_type}, :equal, :employee))
d1.add_condition_set(cd1)

d2 = Discount.new("Affiliate discount", :percentage, 10)
cd2 = ConditionSet.new(:and)
cd2.add_condition(Condition.new(Proc.new{|cart| cart.user.user_type}, :equal, :affiliate))
d2.add_condition_set(cd2)

d3 = Discount.new("Two year member discount", :percentage, 5)
cd3 = ConditionSet.new(:and)
cd3.add_condition(Condition.new(Proc.new{|cart| cart.user.date_joined }, :less_than, Proc.new{Date.today - 730}))
d3.add_condition_set(cd3)

d4 = Discount.new("$5 discount", :value, Proc.new{|cart| (cart.bill_amount.to_i/100) * 5})
cd4 = ConditionSet.new(:and)
cd4.add_condition(Condition.new(Proc.new{|cart| cart.bill_amount}, :greater_than, 100))
d4.add_condition_set(cd4)

store.add_discount(d1)
store.add_discount(d2)
store.add_discount(d3)
store.add_discount(d4)

user1 = User.new("Bob")
user2 = User.new("Bill")
user2.date_joined = Date.new(2008, 10, 10)
user3 = Affiliate.new("Steve")
user4 = Employee.new("Larry")
user3.date_joined = Date.new(2008, 10, 10)

cart = Cart.new(user1, store)
cart.add_item(store.find_product("E01"), 2)
cart.add_item(store.find_product("E02"), 1)
cart.add_item(store.find_product("G01"), 5)
cart.add_item(store.find_product("G02"), 3)
cart.add_item(store.find_product("G03"), 10)

puts "Cart for #{cart.user.name}"
puts "Code\tName\t\tPrice\tQnty\tSub total"
puts cart.to_s
puts "Total\t\t\t\t\t#{cart.bill_amount}"
puts "Discount\t\t\t\t#{cart.discount_amount}"
puts "Payable\t\t\t\t\t#{cart.final_payable}"

cart = Cart.new(user2, store)
cart.add_item(store.find_product("E01"), 2)
cart.add_item(store.find_product("E02"), 1)
cart.add_item(store.find_product("G01"), 5)
cart.add_item(store.find_product("G02"), 3)
cart.add_item(store.find_product("G03"), 10)

puts "Cart for #{cart.user.name}"
puts "Code\tName\t\tPrice\tQnty\tSub total"
puts cart.to_s
puts "Total\t\t\t\t\t#{cart.bill_amount}"
puts "Discount\t\t\t\t#{cart.discount_amount}"
puts "Payable\t\t\t\t\t#{cart.final_payable}"


cart = Cart.new(user4, store)
cart.add_item(store.find_product("E01"), 2)
cart.add_item(store.find_product("E02"), 1)
cart.add_item(store.find_product("G01"), 5)
cart.add_item(store.find_product("G02"), 3)
cart.add_item(store.find_product("G03"), 10)
puts "Cart for #{cart.user.name}"
puts "Code\tName\t\tPrice\tQnty\tSub total"
puts cart.to_s
puts "Total\t\t\t\t\t#{cart.bill_amount}"
puts "Discount\t\t\t\t#{cart.discount_amount}"
puts "Payable\t\t\t\t\t#{cart.final_payable}"

cart = Cart.new(user3, store)
cart.add_item(store.find_product("E01"), 2)
cart.add_item(store.find_product("E02"), 1)
cart.add_item(store.find_product("G01"), 5)
cart.add_item(store.find_product("G02"), 3)
cart.add_item(store.find_product("G03"), 10)
puts "Cart for #{cart.user.name}"
puts "Code\tName\t\tPrice\tQnty\tSub total"
puts cart.to_s
puts "Total\t\t\t\t\t#{cart.bill_amount}"
puts "Discount\t\t\t\t#{cart.discount_amount}"
puts "Payable\t\t\t\t\t#{cart.final_payable}"
