class Storybook < ActiveRecord::Base
  belongs_to :user
  has_many :scenes
end
