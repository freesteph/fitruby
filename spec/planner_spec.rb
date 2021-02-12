require_relative '../lib/planner.rb'

require 'timecop'

describe Planner do
  subject { Planner.new("/home/steph/Documents/cyborg/fitness") }

  it "needs a valid directory to initialise" do
    expect { Planner.new("foobar") }.to raise_error(/cannot read workout directory/)
  end

  describe "next_workout" do
    it "returns the file named `next.yml`" do
      expect(subject.next_workout).to eq '/home/steph/Documents/cyborg/fitness/next.yml'
    end
  end

  describe "schedule_next_workout!" do
    before do
      allow(File).to receive(:copy_stream)
      allow(File).to receive(:write)

      allow(subject).to receive(:upgrade_workout).and_return 'harder better faster stronger'

      Timecop.freeze(2018, 5, 14)

      subject.schedule_next_workout!
    end

    after do
      Timecop.return
    end

    it "writes the next workout to a new file with the current date" do
      expect(File).to have_received(:copy_stream).with(
                        '/home/steph/Documents/cyborg/fitness/next.yml',
                        '/home/steph/Documents/cyborg/fitness/2018-05-14.yml'
                      )
    end

    it "writes a new next.yml file with the upgraded workout" do
      expect(File).to have_received(:write).with(
                        '/home/steph/Documents/cyborg/fitness/next.yml',
                        'harder better faster stronger'
                      )
    end
  end

  describe "upgrade_workout" do
    before do
      f = File.read(File.expand_path("../dummy.yml", __FILE__))

      allow(File).to receive(:read).and_return f
    end

    let(:new_workout) { YAML.safe_load(subject.upgrade_workout) }

    it "bumps the default reps" do
      expect(new_workout['workout']['reps']).to eq 9
    end

    context "when an exerice has a reps value" do
      let(:ex) { find_ex_by_name(new_workout, 'g') }

      it "bumps it" do
        expect(ex['reps']).to eq 11
      end
    end

    context "when an exerice does not have a rep value" do
      let(:ex) { find_ex_by_name(new_workout, 'a1') }

      it "doesn't touch it" do
        expect(ex.keys).to_not include('reps')
      end
    end
  end

  def find_ex_by_name(workout, name)
    workout['workout']['sequence'].find { |e| e['name'] == name }
  end
end
