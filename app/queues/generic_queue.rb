class GenericQueue
  def self.logger
    Rails.logger
  end

  def self.perform
    raise 'This should be implemented in a subclass'
  end
end
