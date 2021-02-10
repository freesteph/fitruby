require_relative './workout.rb'
require 'colorize'

path = ARGV.first

class ExerciceLogger
  def self.log(ex, &block)
    header = "[#{ex.name}]".red +
             "[#{ex.serie}/#{ex.series}]".yellow +
             "(#{ex.reps} repetitions)".green +
             "#{ex.percentage}% ".blue

    puts header + block.call
  end
end

class Runner
  def initialize(path)
    @workout = Workout.new(path)

    @workout.add_observer(self)
  end

  def go!
    puts "Press Enter when you're ready:"

    gets

    @workout.start!

    @workout.current.next!
  end

  def update(exercice)
    if @workout.finished?
      puts "Well done, it's over!"
    else
      handle_exercice(exercice)
    end
  end

  def handle_exercice ex
    case ex.state
    when :resting
      ExerciceLogger.log(ex) { "Rest for #{ex.rest_between} seconds..." }
      sleep ex.rest_between
      puts "\a"

      ex.next!
    when :skipped
      ExerciceLogger.log(ex) { "Skipping: #{ex.skip}..." }

      @workout.current.next!
    when :finished
      ExerciceLogger.log(ex) { "Finished, well done." }

      unless ex.rest_after.nil?
        ExerciceLogger.log(ex) { "Final rest of #{ex.rest_after} seconds..." }
        sleep ex.rest_after
      end

      puts "WORKOUT IS #{@workout.percentage}% DONE".red

      @workout.current.next!
    when :active
      ExerciceLogger.log(ex) { "Go go go! Press enter when done: " }
      gets

      ex.next!
    end
  end
end

r = Runner.new(path)
r.go!
