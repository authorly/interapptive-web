class Settings < ActiveRecord::Base
  belongs_to :font
  belongs_to :storybook
  belongs_to :scene
end
