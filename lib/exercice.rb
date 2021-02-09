require 'observer'

class Exercice
  include Observable

  attr_accessor :reps,
                :series,
                :rest_between,
                :rest_after,
                :name,
                :state,
                :accomplished,
                :serie

  STATES = %i[pending active resting finished].freeze

  def initialize(series:, reps:, rest_between:, name:, rest_after:)
    @state = :pending

    @series = series
    @name = name
    @reps = reps
    @rest_between = rest_between
    @rest_after = rest_after

    @accomplished = 0
    @serie = 1
  end

  def run!
    next!
  end

  def finished?
    state != :pending &&
      @accomplished == @series &&
      @serie = @series
  end

  # | accomplished | series
  # |----
  # | 0 | 3
  # | 1 | 3
  # | 2 | 3
  # | 3 | 3
  def last_run?
    @serie == @series
  end

  def next!
    case @state
    when :pending
      @state = :active
    when :active
      @accomplished += 1

      if finished?
        @state = :finished
      else
        @state = :resting
      end
    when :resting
      @serie += 1
      @state = :active
    end

    changed

    notify_observers(self)
  end

  def percentage
    ((@accomplished * 1.0 / @series) * 100).round
  end
end
