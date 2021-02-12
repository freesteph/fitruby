require 'date'
require 'yaml'

class Planner
  attr_accessor :path

  def initialize(path)
    raise "cannot read workout directory" if not Dir.exist? path

    @path = path
  end

  def next_workout
    File.join(path, 'next.yml')
  end

  def schedule_next_workout!
    date = Time.now.to_s.split(" ").first

    File.copy_stream(next_workout, File.expand_path("../#{date}.yml", next_workout))
    File.write(next_workout, upgrade_workout)
  end

  def upgrade_workout
    edit_yaml_file(next_workout) do |workout|
      workout["workout"]["reps"] += 1

      workout["workout"]["sequence"].each do |exercice|
        exercice["reps"] += 1 unless exercice["reps"].nil?
      end

      workout
    end
  end

  private

  def edit_yaml_file(path)
    attrs = YAML.safe_load(File.read(path))

    res = yield(attrs)

    res.to_yaml
  end
end
