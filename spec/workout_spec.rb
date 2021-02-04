describe Workout do
  subject { Workout.new(File.expand_path("../../dummy.yml", __FILE__)) }

  before do
    @ex = instance_double("Exercice")

    allow(Exercice).to receive(:new).and_return @ex
    allow(@ex).to receive(:add_observer)
  end

  it "maps the exercices" do
    expect(subject.exercices.length).to eq 6
  end

  it "can enforce default properties" do
    Workout.new(File.expand_path("../../dummy.yml", __FILE__))

    expect(Exercice).to have_received(:new).at_least(1).times.with(a_hash_including(series: 6))
  end

  it "has no current exercice" do
    expect(subject.current).to be_nil
  end

  it "subscribes to their updates" do
    expect(@ex).to have_received(:add_observer).exactly(6).times.with(subject)
  end

  describe "start!" do
    it "sets the current exercice" do
      subject.start!

      expect(subject.current).to_not be_nil
    end
  end

  describe "percentage" do
    before do
      allow(@ex).to receive(:percentage).and_return(100, 100, 100, 50, 0, 0)
    end

    it "sums up the exercices percentage" do
      expect(subject.percentage).to eq 58
    end
  end
end
