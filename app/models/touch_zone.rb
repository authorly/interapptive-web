class TouchZone < ActiveRecord::Base
  has_one :video
  has_one :audio
end
