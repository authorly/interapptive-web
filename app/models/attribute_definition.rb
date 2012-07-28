class AttributeDefinition < ActiveRecord::Base
  self.inheritance_column = 'something_other_than_type'

  belongs_to :action_definition
end
