require "securerandom"

class User
  attr_accessor :name, :id, :user_type, :date_joined

  def initialize(name)
    self.name = name
    self.date_joined = Date.today
    self.id = SecureRandom.uuid
    self.user_type ||= :normal
  end
end

class Employee < User
  def initialize(name)
    self.user_type = :employee
    super(name)
  end
end

class Affiliate < User
  def initialize(name)
    self.user_type = :affiliate
    super(name)
  end
end
