# frozen_string_literal: true

require 'yaml'
require 'colorize'

workout = YAML.safe_load(File.read('./nerea.yml'))['workout']

default_reps = workout['reps']
default_series = workout['series']
default_between = workout['between']

print 'Ready?'

gets

workout['sequence'].each do |exercice|
  name = exercice['name']
  series = exercice['series'] || default_series
  reps = exercice['reps'] || default_reps
  between = exercice['between'] || default_between

  series.times do |serie|
    header = "[#{name}]".red +
             "[#{serie + 1}/#{series}]".yellow +
             "(#{reps} repetitions)".green

    print "#{header}\a GO! press when done..."
    gets

    unless (serie + 1) == series
      puts "#{header} rest for #{between} seconds"
      sleep(between)
    end
  end

  after = exercice['after'] || between

  puts "--- Rest for #{after} seconds..."

  sleep(after)

  puts 'NEXT EXERCICE'
end

puts 'Workout complete!'.white.on_green
