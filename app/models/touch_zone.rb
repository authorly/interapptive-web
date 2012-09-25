class TouchZone < ActiveRecord::Base
  belongs_to :scene
  belongs_to :video
  belongs_to :audio
  belongs_to :action
end
