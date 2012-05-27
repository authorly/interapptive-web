class Action < ActiveRecord::Base
  belongs_to :scene
  belongs_to :action_definition
  has_many   :attributes
end
