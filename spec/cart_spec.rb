require "spec_helper"

describe Cart do
  subject(:cart){
    @cart
  }

  before do
    user = User.new("Bob")
    store = Store.new("Test store")
    @cart  = Cart.new(user, store)
    test_product_type = ProductType.new("Test product range")
    cart.store.add_product_type(test_product_type)
    product = Product.new("G01", "Test product", 100, test_product_type)
    cart.store.add_product(product)
    product2 =Product.new("G02", "Test product 1", 100, test_product_type)
    cart.store.add_product(product2)
  end

  it "show add products in desired quantity to cart" do
    store = cart.store
    cart.add_item(store.products.first, 10)
    cart.items_count.should eq(1)

    cart.add_item(store.products.last, 10)
    cart.items_count.should eq(2)
  end

  it "should not add same product twice" do
    store = cart.store
    cart.add_item(store.products.first, 10)
    cart.items_count.should eq(1)
    cart.add_item(store.products.first, 10)
    cart.items_count.should eq(1)
  end

  it "should remove product" do
    store = cart.store
    cart.add_item(store.products.first, 10)
    cart.items_count.should eq(1)
    cart.remove_item(store.products.first)
    cart.items_count.should eq(0)
  end

  it "show increase count of product quatity if added twice" do
    store = cart.store
    cart.add_item(store.products.first, 10)
    cart.items_count.should eq(1)
    cart.add_item(store.products.first, 12)
    cart.items_count.should eq(1)
    cart.items.find{|x| x.product==store.products.first}.quantity.should eq(22)
  end

  it "should calculate bill amount correctly" do
    store = cart.store
    cart.add_item(store.products.first, 10)
    cart.items_count.should eq(1)
    cart.add_item(store.products.first, 12)
    cart.items_count.should eq(1)

    cart.add_item(store.products.last, 20)
    cart.items_count.should eq(2)
    cart.bill_amount.should eq(store.products.first.value * 22 + store.products.last.value * 20)
  end

  it "should calculate bill amount correctly after removal of a product" do
    store = cart.store
    cart.add_item(store.products.first, 10)
    cart.add_item(store.products.last, 20)
    cart.items_count.should eq(2)

    cart.bill_amount.should eq(store.products.first.value * 10 + store.products.last.value * 20)

    cart.remove_item(store.products.last)
    cart.bill_amount.should eq(store.products.first.value * 10)
  end

  it "should discount correctly" do
    store = cart.store
    discount=Discount.new("Test discount", :percentage, 10)
    cs = ConditionSet.new
    cs.add_condition(Condition.new(Proc.new{|cart| cart.user.user_type}, :equal, :normal))
    discount.add_condition_set(cs)
    store.add_discount(discount)

    cart.add_item(store.products.first, 10)
    cart.add_item(store.products.last, 20)
    cart.items_count.should eq(2)
    cart.bill_amount.should eq(store.products.first.value * 10 + store.products.last.value * 20)
    cart.discount_amount.should eq(cart.bill_amount * 0.1)

    store.remove_discount(discount)
    cart.discount_amount.should eq(0)
  end

  it "should apply only one percentage discounts if two are applicable" do
    store = cart.store
    discount1=Discount.new("Test discount", :percentage, 10)
    cs = ConditionSet.new
    cs.add_condition(Condition.new(Proc.new{|cart| cart.user.user_type}, :equal, :normal))
    discount1.add_condition_set(cs)
    store.add_discount(discount1)

    discount2=Discount.new("Test discount", :percentage, 15)
    cs = ConditionSet.new
    cs.add_condition(Condition.new(Proc.new{|cart| cart.user.user_type}, :equal, :normal))
    discount2.add_condition_set(cs)
    store.add_discount(discount2)

    cart.add_item(store.products.first, 10)
    cart.add_item(store.products.last, 20)
    cart.items_count.should eq(2)
    cart.bill_amount.should eq(store.products.first.value * 10 + store.products.last.value * 20)
    cart.discount_amount.should eq(cart.bill_amount * 0.15)

    store.remove_discount(discount2)
    cart.discount_amount.should eq(cart.bill_amount * 0.1)

    store.add_discount(discount2)
    cart.discount_amount.should eq(cart.bill_amount * 0.15)
  end

  it "should not apply one percentage and one value discount" do
    store = cart.store
    store.discounts.each{|discount| store.remove_discount(discount)}

    discount1=Discount.new("Test discount", :percentage, 10)
    cs = ConditionSet.new
    cs.add_condition(Condition.new(Proc.new{|cart| cart.user.user_type}, :equal, :normal))
    discount1.add_condition_set(cs)
    store.add_discount(discount1)

    discount2=Discount.new("Test discount", :value, 15)
    cs = ConditionSet.new
    cs.add_condition(Condition.new(Proc.new{|cart| cart.user.user_type}, :equal, :normal))
    discount2.add_condition_set(cs)
    store.add_discount(discount2)

    cart.add_item(store.products.first, 10)
    cart.add_item(store.products.last, 20)
    cart.items_count.should eq(2)
    cart.bill_amount.should eq(store.products.first.value * 10 + store.products.last.value * 20)
    cart.discount_amount.should eq(cart.bill_amount * 0.1 + 15)

    store.remove_discount(discount2)
    cart.discount_amount.should eq(cart.bill_amount * 0.1)

    store.remove_discount(discount1)
    store.add_discount(discount2)
    cart.discount_amount.should eq(15)
  end
end
