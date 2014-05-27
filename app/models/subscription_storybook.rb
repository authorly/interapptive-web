# SubscriptionStorybook represents a storybook and its
# contents once it has been published to the subscription
# platform.
#
# `storybook_json`: Has the JSON of the storybook being
#    published.
# `assets`: Has link to a zip file containing all the
#    media files necessary for the storybook.
class SubscriptionStorybook < ActiveRecord::Base
  mount_uploader :assets, PublishedStorybookResourceUploader
  mount_uploader :cover_image, SubscriptionCoverImageUploader

  serialize :storybook_json, Hash

  belongs_to :storybook

  has_one :subscription_publish_request

  validates :cover_image, presence: true
  validates :storybook, presence: true

end
