class ActionDefinition < ActiveRecord::Base
  has_many :attribute_definitions

  default_scope where(:enabled => true)
end
