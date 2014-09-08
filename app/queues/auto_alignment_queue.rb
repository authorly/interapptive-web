require 'resque-loner'

require 'interapptive/auto_aligner/auto_aligner'

class AutoAlignmentQueue < GenericQueue
  include Resque::Plugins::UniqueJob

  @queue = :auto_alignment

  def self.perform(keyframe_id)
    logger.info "Auto aligning kyeframe with id #{keyframe_id}"
    keyframe = Keyframe.find(keyframe_id)

    auto_aligner = AutoAligner.new(keyframe)
    begin
      keyframe.update_attribute(:auto_align_state, 'in-progress')
      auto_aligner.align
    ensure
      keyframe.update_attribute(:auto_align_state, 'done')
    end
  end
end
