require 'pirate_command'

class PirateGame::Stage
  attr_accessor :level, :players, :all_items,
    :actions_completed, :begin_time

  ITEMS_PER_BRIDGE = 6
  DURATION = 60

  def initialize(level, players)
    @level = level
    @players = players
    @actions_completed = []
    generate_all_items

    @begin_time = Time.now
  end

  def time_left
    [0, (begin_time + DURATION) - Time.now].max
  end

  def status
    if time_left > 0
      'In Progress'
    else
      passed? ? 'Success' : 'Failure'
    end
  end

  def generate_all_items
    @all_items = []

    while @all_items.length < @players*ITEMS_PER_BRIDGE
      thing = PirateCommand.thing
      @all_items << thing unless @all_items.include?(thing)
    end
    @boards = @all_items.each_slice(ITEMS_PER_BRIDGE).to_a
  end

  def bridge_for_player
    @boards.shift
  end

  def complete action, from
    @actions_completed << [action, from]
  end

  def required_actions
    @players*3 + 1
  end

  def passed?
    @actions_completed.length >= required_actions
  end

end