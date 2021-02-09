require 'observer'
require 'yaml'

require_relative './exercice.rb'

class Workout
  include Observable

  attr_reader :exercices, :current

  def initialize(path)
    @config = YAML.safe_load(File.read(path))

    workout = @config['workout']

    default_reps = workout['reps']
    default_series = workout['series']
    default_between = workout['between']
    default_rest_after = workout['rest_after']

    @exercices = workout['sequence'].map do |exo|
      Exercice.new(
        name: exo['name'],
        series: exo['series'] || default_series,
        reps: exo['reps'] || default_reps,
        rest_between: exo['between'] || default_between,
        rest_after: exo['rest_after'] || default_rest_after
      )
    end

    @exercices.each do |exo|
      exo.add_observer(self)
    end
  end

  def update(exo)
    changed

    if exo.finished?
      unless finished?
        @current = @exercices.find { |e| e.state == :pending }
      end
    end

    notify_observers(exo)
  end

  def finished?
    @exercices.all?(&:finished?)
  end

  def start!
    @current = @exercices.first
  end

  def percentage
    (@exercices.map(&:percentage).sum / @exercices.length).round
  end
end
