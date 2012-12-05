class KeyframeText < ActiveRecord::Base
  belongs_to :keyframe

  def self.reorder(ids)
    return [] if ids.blank?
    ids.each_with_index do |id, index|
      update_all(["sync_order = ?, updated_at = NOW()", index + 1], ["id = ?", id])
    end
    where(:id => ids).order(:sync_order)
  end
end
