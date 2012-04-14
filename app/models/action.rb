class Action < ActiveRecord::Base
  has_many :attributes
  has_many :action_groups
  has_many :scenes, :through => :action_groups
end
