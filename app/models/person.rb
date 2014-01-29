class Person
  include ActiveModel::Validations

  validates_presence_of :name, :address

  attr_accessor :name, :address

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

end
