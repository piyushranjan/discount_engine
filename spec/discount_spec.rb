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

  it "should be able to handle two condition sets" do
    c1 = ConditionSet.new
    c1.add_condition(Condition.new(Proc.new{|cart| cart.items_count}, :equal, @cart.items_count))
    discount.add_condition_set(c1)
    discount.evaluate(@cart).should be_true

    c2 = ConditionSet.new
    c2.add_condition(Condition.new(Proc.new{|cart| cart.user.user_type}, :equal, :normal))
    discount.add_condition_set(c2)
    discount.evaluate(@cart).should be_true

    c2.add_condition(Condition.new(Proc.new{|cart| cart.user.user_type}, :equal, :employee))
    discount.evaluate(@cart).should be_false

    discount.and_or = :or
    discount.evaluate(@cart).should be_true

  end

  context "simple conditions" do
    it "should evaluate equal to predicate" do
      c = ConditionSet.new
      c.add_condition(Condition.new("a", :equal, "b"))
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_false

      c.add_condition(Condition.new("b", :equal, "b"))
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_false
      c.and_or = :or
      discount.evaluate(@cart).should be_true
    end

    it "should evaluate less than predicate" do
      c = ConditionSet.new
      c.add_condition(Condition.new(1, :less_than, 2))
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_true
    end

    it "should evaluate less than equal to predicate" do
      c = ConditionSet.new
      c.add_condition(Condition.new(2, :less_than_equal, 2))
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_true

      c.add_condition(Condition.new(4, :less_than_equal, 3))
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_false
    end

    it "should evaluate greater than equal to predicate" do
      c = ConditionSet.new
      c.add_condition(Condition.new(2, :greater_than_equal, 2))
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_true

      c.add_condition(Condition.new(1, :greater_than_equal, 2))
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_false
    end

    it "should evaluate not predicate" do
      c = ConditionSet.new
      c.add_condition(Condition.new(2, :not, 3))
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_true

      c.add_condition(Condition.new(2, :not, 4))
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_true

      bad_condition = Condition.new(2, :not, 2)
      c.add_condition(bad_condition)
      discount.add_condition_set(c)
      discount.evaluate(@cart).should be_false

      c.delete_condition(bad_condition)
      discount.evaluate(@cart).should be_true
    end

  end

end
