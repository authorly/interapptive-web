class Action < ActiveRecord::Base
  belongs_to :scene
  belongs_to :action_definition
  has_many   :action_attributes, :class_name => 'Attribute'

  delegate :name, :to => :action_definition
end
