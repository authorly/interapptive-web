class Keyframe < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  mount_uploader :audio, KeyframeAudioUploader

  belongs_to :scene
  belongs_to :preview_image, :class_name => 'Image'

  has_many :texts, :class_name => 'KeyframeText', :dependent => :destroy

  serialize :widgets

  validates :position, inclusion: { in: [nil] }, if: :is_animation, allow_nil: true
  validates :is_animation, uniqueness: { scope: :scene_id }, if: :is_animation

  def audio_text
    texts.order(:sync_order).collect(&:content).join(' ')
  end

  def save_and_sync_text
    return [] if audio.blank? || texts.empty?

    resp = []
    begin
      audio_text_file = save_text
      audio_file = download_audio_file
      resp = sync_text(audio_file, audio_text_file)
    ensure
      audio_text_file.unlink
      audio_file.unlink
    end
    resp
  end

  def save_text
    tf = Tempfile.new(['audio_text', '.txt'], Rails.root.to_s + '/tmp')
    tf << audio_text
    tf.open
    tf
  end

  def sync_text(audio_file, audio_text_file)
    begin
      Aligner.new(audio_file.path, audio_text_file.path).to_a
    rescue Aligner::UnprocessableFileError
      return []
    end
  end

  def download_audio_file
    tf = Tempfile.new(['audio_file', '.wav'], Rails.root.to_s + '/tmp')
    tf.binmode
    open(audio.sphinx_audio.url, 'rb') do |read_audio_file|
      tf.write(read_audio_file.read)
    end
    tf.open
    tf
  end

  def audio_as_jquery_upload_response
    {
        'id' => self.id,
        'name' => read_attribute(:audio),
        'size' => audio_size,
        'url' => self.audio_url,
        'content_highlight_times' => self.content_highlight_times,
        'delete_url' => "/keyframes/#{self.id}/audio",
        'delete_type' => 'DELETE'
    }
  end

  def audio_size
    return 0 unless audio
    self.audio.size
  end

  def audio_url
    return '' unless audio
    audio.url
  end
  
  def as_json(options)
    super.merge({
      preview_image_url: preview_image.try(:image).try(:url)
    })
  end


  private

  def one_animation_keyframe_per_scene
    if is_animation
      animations = scene.keyframes.where(is_animation.true).reject{|k| k.id == id}
      errors[:is_animation] << :only_one
    end
  end
end
