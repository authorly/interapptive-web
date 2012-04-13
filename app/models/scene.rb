class Scene < ActiveRecord::Base
  belongs_to :storybook
  has_many :keyframes
end
