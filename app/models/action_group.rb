class ActionGroup < ActiveRecord::Base
  belongs_to :action
  belongs_to :scene
end
