Fog.mock!
Fog.credentials = {
  :aws_access_key_id      => 'AKIAJ3N4AG2EGQRMHXRQ',
  :aws_secret_access_key  => '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'
}
connection = Fog::Storage.new(:provider => 'AWS')
connection.directories.create(:key => 'authorly-test')
