class Asset < ActiveRecord::Base
  belongs_to :storybook

  validates_presence_of :type
  serialize :meta_info, Hash

  def self.create_asset(storybook, file)
    extension = File.extname(file.original_filename)[1..-1]
    if Video.valid_extension?(extension)
      storybook.videos.create(video: file)
    elsif Sound.valid_extension?(extension)
      storybook.sounds.create(sound: file)
    elsif Image.valid_extension?(extension)
      storybook.images.create(image: file)
    end
  end

  def as_jquery_upload_response
    {
      meta_info: meta_info
    }
  end
end
