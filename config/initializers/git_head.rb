Rails.configuration.git_head = IO.popen('git rev-parse HEAD').read
