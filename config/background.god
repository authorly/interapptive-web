RAILS_ROOT = File.join(File.dirname(__FILE__), '..')
RAILS_ENV   = ENV['RAILS_ENV']  || "compilation"
#NUM_WORKERS = RAILS_ENV == 'production' ? 5 : 2
NUM_WORKERS = 1

NUM_WORKERS.times do |num|
  God.watch do |w|
    w.dir             = "#{RAILS_ROOT}"
    w.name            = "resque-#{num}"
    w.group           = 'resque'
    w.interval        = 30.seconds
    w.log             = "#{RAILS_ROOT}/../authorly_resque_god.log"
    w.env             = {"QUEUE"=>"*", "RAILS_ENV"=>RAILS_ENV}
    w.start           = "cd #{RAILS_ROOT} && bundle exec rake -f #{RAILS_ROOT}/Rakefile environment resque:work --trace"
    w.stop_signal     = 'QUIT'
    w.stop_timeout    = 20.seconds

    w.uid = 'curiousminds'
    w.gid = 'staff'

    w.behavior(:clean_pid_file)

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end
