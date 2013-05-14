class AbstractStorybookApplication
  CRUCIBLE_RESOURCES_DIR = File.join(Rails.root, '../../Crucible/HelloWorld/Resources')
  # Following should live outside of the codebase. So that
  # configurations could be changed without redeploying
  # the application.
  FOG_DIRECTORY          = Fog::Storage.new(
    :provider               => 'AWS',
    :aws_access_key_id      => 'AKIAJ3N4AG2EGQRMHXRQ',
    :aws_secret_access_key  => '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'
  ).directories.get('interapptive')

  @downloadable_file_extension_regex = nil

  def initialize(storybook, storybook_json, target)
    @storybook       = storybook
    @json            = storybook_json
    @transient_files = []
    @target          = target
  end

  def logger
    Rails.logger
  end

  def download_files_and_sanitize_json(hash_or_array)
    case hash_or_array
    when Hash
      hash_or_array.each do |key, value|
        if value.is_a?(Hash) || value.is_a?(Array)
          download_files_and_sanitize_json(value)
        else
          file_name = download_file(value)
          hash_or_array[key] = file_name
        end
      end
    when Array
      hash_or_array.each_with_index do |value, key|
        if value.is_a?(Hash) || value.is_a?(Array)
          download_files_and_sanitize_json(value)
        else
          file_name = download_file(value)
          hash_or_array[key] = file_name
        end
      end
    end
    hash_or_array
  end

  def download_file(file)
    return file unless file.is_a?(String)
    file_ext = File.extname(file)

    if file_ext.match(self.class.downloadable_file_extension_regex)
      if file.match(/^http/)
        new_file_name = SecureRandom.hex
        File.open(File.join(CRUCIBLE_RESOURCES_DIR, new_file_name + file_ext), 'wb+') do |asset|
          open(file, 'rb') do |read_file|
            asset << read_file.read
            @transient_files << asset.path
          end
        end
        return File.basename(@transient_files.last)
      elsif file.match(/^\/assets/)
        return File.basename(file)
      end
    end
    file
  end

  def cleanup
    begin
      File.delete(*@transient_files)
    rescue => e
      logger.info "Cleanup failed for #{@storybook.id}"
      logger.info e.message + "\n" + e.backtrace.join("\n")
    end
  end

  def compile
    raise 'This should be implemented in a subclass'
  end

  def upload_compiled_application
    raise 'This should be implemented in a subclass'
  end

  def send_notification
    raise 'This should be implemented in a subclass'
  end

  # Change this method to include any new uploaders to take care that
  # introduce new type of files in the application
  def self.downloadable_file_extension_regex
    return @downloadable_file_extension_regex if @downloadable_file_extension_regex

    downloadable_extensions = FontUploader.new.extension_white_list +
      ImageUploader.new.extension_white_list +
      SoundUploader.new.extension_white_list +
      VideoUploader.new.extension_white_list
    downloadable_extensions.uniq!
    @downloadable_file_extension_regex = Regexp.new(downloadable_extensions.join('|'), true) # true means case insensitive
    @downloadable_file_extension_regex
  end

  private

  def write_json_file
    File.open(File.join(CRUCIBLE_RESOURCES_DIR, 'structure-ipad.json'), 'w') do |f|
      f.write(ActiveSupport::JSON.encode(@json_hash))
    end
  end
end
