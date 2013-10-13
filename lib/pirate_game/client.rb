require 'shuttlecraft'
require 'thread'

class PirateGame::Client < Shuttlecraft

  attr_reader :msg_log, :bridge

  def initialize(opts={})
    opts[:protocol] ||= PirateGame::Protocol.default

    super(opts)

    @bridge = nil
    @msg_log = []
    @msg_log_mutex = Mutex.new
  end

  def clicked button
    @mothership.write [:button, button, Time.now.to_i, DRb.uri]
  end

  def start_stage(items)
    @bridge = PirateGame::Bridge.new(items)
  end

  def teammates
    registered_services.collect{|name,_| name}
  end

  def perform_action action
    if @mothership
      @mothership.write [:action, action, Time.now, DRb.uri]
    end
  end

  def broadcast(msg)
    for name,uri in registered_services
      begin
        remote = DRbObject.new_with_uri(uri)
        remote.say(msg, DRb.uri)
      rescue DRb::DRbConnError
      end
    end
  end

  def say(msg, from)
    @msg_log_mutex.synchronize do
      name = get_name_from_uri(from)
      @msg_log << [msg, name || 'unknown']
    end
    begin
      remote = DRbObject.new_with_uri(from)
      remote.message_reciept(@name)
    rescue DRb::DRbConnError
    end
  end

  def message_reciept(from)
    puts "reciept from #{from}"
  end

  def get_name_from_uri(uri)
    from = registered_services.detect{|n, u| uri == u}
    from[0] if from
  end
end
