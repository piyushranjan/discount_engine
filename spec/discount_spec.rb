require "spec_helper"

describe Discount, "#add_item" do
  subject(:discount){
    @discount
  }

  before(:all) do
    user = User.new("Bob")
    store = Store.new("Test store")
    @cart  = Cart.new(user, store)

    test_product_type = ProductType.new("Test product range")
    @cart.store.add_product_type(test_product_type)
    product = Product.new("G01", "Test product", 100, test_product_type)
    @cart.store.add_product(product)
    product2 =Product.new("G02", "Test product 1", 100, test_product_type)
    @cart.store.add_product(product2)
  end

  before do
    @discount=Discount.new("Test discount", :percentage, 10)
  end

  it "should have discount type" do
    discount.discount_type.should eq(:percentage)
    discount.discount_type = :value
    discount.discount_type.should eq(:value)
  end

  it "should be able to add/remove condition sets" do
    c = ConditionSet.new
    discount.add_condition_set(c)
    discount.condition_sets.length.should eq(1)

    discount.remove_condition_set(c)
    discount.condition_sets.length.should eq(0)
  end

  it "should return correct amount of discount on a cart" do
    discount.get_amount(@cart).should eq(0)
    c = ConditionSet.new
    c.add_condition(Condition.new(Proc.new{|cart| cart.items_count}, :equal, 1))
    discount.add_condition_set(c)
    discount.discount_type = :value
    discount.discount_value = 1
    discount.get_amount(@cart).should eq(0)
    store = @cart.store
    @cart.add_item(store.products.first, 10)
    discount.get_amount(@cart).should eq(1)

    discount.discount_type = :percentage
    discount.discount_value = 10
    discount.get_amount(@cart).should eq(@cart.bill_amount * 0.1)

    discount.discount_type = :percentage
    discount.discount_value = Proc.new{|cart| cart.items_count * 2}
    discount.get_amount(@cart).should eq(@cart.bill_amount * 0.02)

    discount.discount_type = :value
    discount.discount_value = Proc.new{|cart| cart.items_count * 2}
    discount.get_amount(@cart).should eq(2)
  end

  it "should evaluate conditions based on and_or variable" do
    c = ConditionSet.new
    c.add_condition(Condition.new(Proc.new{|cart| cart.items_count}, :equal, @cart.items_count))
    c.add_condition(Condition.new(Proc.new{|cart| cart.items_count}, :equal, @cart.items_count+1))
    discount.add_condition_set(c)
    discount.evaluate(@cart).should be_false

    c.and_or = :or
    discount.evaluate(@cart).should be_true
  end
end
