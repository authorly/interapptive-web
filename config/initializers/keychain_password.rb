keychain_password_file_path = File.join(Rails.root, 'config', 'keychain_password.txt')

if File.exist?(keychain_password_file_path)
  Rails.configuration.crucible_keychain_password = IO.read(keychain_password_file_path).chomp
end
