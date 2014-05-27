# SubscriptionPublishRequest represents a user request to
# publish their storybook to the subscription(bookfair)
# platform.
#
# The `status` column may have following values:
#
# - 'review-required': The initial and default state of a request.
#   It represents the case when a user has just enqueued their
#   storybook to be reviewed by an admin.
# - 'ready-to-publish': Once admin has positively reviewed the
#    the storybook, request goes under this state. A worker runs
#    and sends the request to its last state.
# - 'published': The final state of a request. It represents that
#    corresponding storybook was published to the subscription
#    platform.
class SubscriptionPublishRequest < ActiveRecord::Base
  # Default status is `review-required`
  STATUSES = {
    :review_required  => 'review-required',
    :ready_to_publish => 'ready-to-publish',
    :published        => 'published'
  }

  belongs_to :storybook
  belongs_to :subscription_storybook

  validates :storybook, presence: true

  def review_required?
    self.try(:status) == STATUSES[:review_required]
  end

  def publish(subscription_storybook)
    self.status = STATUSES[:published]
    self.subscription_storybook_id = subscription_storybook.id
    self.save
  end
end
