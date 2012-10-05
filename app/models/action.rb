class Action < ActiveRecord::Base
  belongs_to :scene
  belongs_to :action_definition
  has_many   :action_attributes, :class_name => 'Attribute', :dependent => :destroy

  delegate :name, :to => :action_definition

  def as_json(options={})
    includables = {
      :action_definition =>
        {:include => :attribute_definitions},
      :action_attributes =>
        {:include => :attribute_definition}
    }

    super(:include => includables)
  end
end
