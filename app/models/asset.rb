class Asset < ActiveRecord::Base
  belongs_to :storybook

  serialize :meta_info, Hash
end
