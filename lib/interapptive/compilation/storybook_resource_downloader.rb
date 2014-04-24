#
# This class borrows heavily from AbstractStorybookApplication.
# Make sure to change its code if changes are made in AbstractStorybookApplication.
#
require 'zip'

class StorybookResourceDownloader
  CRUCIBLE_RESOURCE_DOWNLOAD_DIR = File.join(Rails.root, '..', '..', 'ResourcesCrucible')
  CRUCIBLE_DIR_TO_BE_ZIPPED      = File.join(CRUCIBLE_RESOURCE_DOWNLOAD_DIR, 'HelloWorld')
  CRUCIBLE_RESOURCES_DIR         = File.join(CRUCIBLE_DIR_TO_BE_ZIPPED, 'Resources')
  CRUCIBLE_ANDROID_DIR           = File.join(CRUCIBLE_DIR_TO_BE_ZIPPED, 'android')
  CRUCIBLE_ANDROID_RES_DIR       = File.join(CRUCIBLE_ANDROID_DIR, 'res')

  ANDROID_ICON_DIRECTORIES = {
    :app_icon_32_32 => 'drawable-ldpi',
    :app_icon_48_48 => 'drawable-mdpi',
    :app_icon_72_72 => 'drawable-hdpi',
    :app_icon_96_96 => 'drawable-xhdpi'
  }

  IOS_ICON_FILE_NAMES = {
    :app_icon_72_72               => ['Icon-72.png', 'Icon@72.png'],
    :app_icon_76_76               => ['Icon@76.png'],
    :app_icon_80_80               => ['Icon@80.png'],
    :app_icon_100_100             => ['Icon@100.png', 'Icon-Small-50@2x.png'],
    :app_icon_114_114             => ['Icon@114.png', 'Icon@2x.png'],
    :app_icon_120_120             => ['Icon@120.png'],
    :app_icon_144_144             => ['Icon-72@2x.png', 'Icon@144.png'],
    :app_icon_152_152             => ['Icon@152.png'],
    :app_icon_20_20               => ['Icon-Small-20.png'],
    :app_icon_40_40               => ['Icon-Small-20@2x.png', 'Icon@40.png'],
    :app_icon_30_30               => ['Icon-Small-30.png'],
    :app_icon_60_60               => ['Icon-Small-30@2x.png'],
    :app_icon_50_50               => ['Icon-Small-50.png', 'Icon@50.png'],
    :app_icon_29_29               => ['Icon-Small.png', 'Icon@29.png'],
    :app_icon_58_58               => ['Icon-Small@2x.png', 'Icon@58.png'],
    :app_icon_57_57               => ['Icon.png', 'Icon@57.png'],
    :app_icon_app_store_512_512   => ['iTunesArtwork.png'],
    :app_icon_app_store_1024_1024 => ['iTunesArtwork@2x.png']
  }

  @downloadable_file_extension_regex = nil

  def initialize(storybook, storybook_json)
    @storybook         = storybook
    @json              = storybook_json
    @transient_files   = {}
    @asset_prefix       = @storybook.title.downcase.gsub(/[^a-zA-Z]/, '') + '_' + @storybook.id.to_s + '_'
  end

  def download_resources
    make_directories
    download_files_and_sanitize_json(ActiveSupport::JSON.decode(@json))
    download_icons
    write_json_file
    self
  end

  def archive
    Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipped_file|
      Dir[File.join(CRUCIBLE_DIR_TO_BE_ZIPPED, '**', '**')].each do |file|
        zipped_file.add(file.sub(CRUCIBLE_DIR_TO_BE_ZIPPED + '/', ''), file)
      end
    end
  end

  def upload_resource_archive
    @storybook.resource_archive = File.open(zip_file_path)
    @storybook.save!
  end

  def cleanup
    FileUtils.rm(zip_file_path, :force => true)
    FileUtils.rm_rf(CRUCIBLE_DIR_TO_BE_ZIPPED)
  end

  def zip_file_name
    @storybook.title.gsub(/[ \/]/, '') + '.zip'
  end

  def zip_file_path
    zip_file_path = File.join(CRUCIBLE_RESOURCE_DOWNLOAD_DIR, zip_file_name)
  end

  def download_files_and_sanitize_json(hash_or_array)
    @json_hash = traverse_json_hash(hash_or_array) do |transient_hash_or_array, key, value|
      file_name = download_file(value)
      transient_hash_or_array[key] = file_name
      transient_hash_or_array
    end
    @json_hash
  end

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

  def send_notification(recipient_email)
    Resque.enqueue(MailerQueue, 'UserMailer', 'storybook_resource_archive_completion_notification', recipient_email, @storybook.resource_archive.url)
  end

  private

  def download_icons
    if @storybook.icon.present?
      save_ios_icon_files
      save_android_icon_files
    end
  end

  def save_ios_icon_files
    IOS_ICON_FILE_NAMES.each do |accessor, names|
      names.each do |name|
        File.open(File.join(CRUCIBLE_RESOURCES_DIR, name), 'wb+') do |icon|
          open(@storybook.icon.app_icon.send(accessor).url, 'rb') do |read_file|
            icon << read_file.read
          end
        end
      end
    end
  end

  def save_android_icon_files
    ANDROID_ICON_DIRECTORIES.each do |accessor, name|
      File.open(File.join(CRUCIBLE_ANDROID_RES_DIR, name, 'icon.png'), 'wb+') do |icon|
        open(@storybook.icon.app_icon.send(accessor).url, 'rb') do |read_file|
          icon << read_file.read
        end
      end
    end
  end

  def make_directories
    FileUtils.mkdir_p(CRUCIBLE_RESOURCES_DIR)
    FileUtils.mkdir_p(CRUCIBLE_ANDROID_DIR)
    FileUtils.mkdir_p(CRUCIBLE_ANDROID_RES_DIR)
    ANDROID_ICON_DIRECTORIES.values.each do |name|
      FileUtils.mkdir_p(File.join(CRUCIBLE_ANDROID_RES_DIR, name))
    end
  end

  def write_json_file
    File.open(File.join(CRUCIBLE_RESOURCES_DIR, 'structure-ipad.json'), 'w') do |f|
      f.write(ActiveSupport::JSON.encode(@json_hash))
    end
  end

  def traverse_json_hash(json_hash_or_array, &block)
    case json_hash_or_array
    when Hash
      json_hash_or_array.each do |key, value|
        if value.is_a?(Hash) || value.is_a?(Array)
          traverse_json_hash(value, &block)
        else
          json_hash_or_array = yield(json_hash_or_array, key, value)
        end
      end
    when Array
      json_hash_or_array.each_with_index do |value, key|
        if value.is_a?(Hash) || value.is_a?(Array)
          traverse_json_hash(value, &block)
        else
          json_hash_or_array = yield(json_hash_or_array, key, value)
        end
      end
    end
    json_hash_or_array
  end

  def download_file(file)
    return file unless file.is_a?(String)
    file_ext = File.extname(file)

    if file_ext.match(self.class.downloadable_file_extension_regex)
      if file.match(/^http/)
        return fetch_file(file, file_ext)

      elsif file.match(/^\/assets/)
        return File.basename(file)
      end
    end
    file
  end

  def fetch_file(url, ext)
    if @transient_files.keys.exclude?(url)
      new_file_name = @asset_prefix + SecureRandom.hex(64).gsub(/[0-9]/, '')
      File.open(File.join(CRUCIBLE_RESOURCES_DIR, new_file_name + ext), 'wb+') do |asset|
        open(url, 'rb') do |read_file|
          asset << read_file.read
          @transient_files[url] = asset.path
        end
      end
    end
    File.basename(@transient_files[url])
  end
end
