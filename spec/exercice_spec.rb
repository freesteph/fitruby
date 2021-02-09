describe Exercice do
  attrs = {
    series: 3,
    reps: 5,
    rest_between: 5,
    name: "a2",
    rest_after: 30
  }

  subject { Exercice.new(attrs) }

  attrs.each do |attr, val|
    it "parses #{attr} correctly" do
      expect(subject.send(attr)).to eq val
    end
  end

  describe "next!" do
    before do
      allow(subject).to receive(:notify_observers)
      allow(subject).to receive(:changed)
    end

    it "sets itself to changed" do
      expect(subject).to receive(:changed)

      subject.next!
    end

    it "notifies observers" do
      expect(subject).to receive(:notify_observers)

      subject.next!
    end
  end

  describe "finished?" do
    context "when the state is pending" do
      it "is false" do
        expect(subject.finished?).to be_falsy
      end
    end

    context "when the accomplished is over the series" do
      before do
        subject.accomplished = subject.series
        subject.state = :active
      end

      it "is true" do
        expect(subject.finished?).to be_truthy
      end
    end
  end

  describe "states" do
    describe "initial state" do
      it "is initially pending" do
        expect(subject.state).to eq :pending
      end

      it "has accomplished as 0" do
        expect(subject.accomplished).to eq 0
      end

      it "moves to active when next! is called the first time" do
        expect { subject.next! }.to change { subject.state }.to :active
      end
    end

    describe "when the exercice is active" do
      before do
        subject.next! # make it active
      end

      it "moves to resting when next! is called" do
        expect { subject.next! }.to change { subject.state }.to :resting
      end

      it "increments the accomplished attribute" do
        expect { subject.next! }.to change { subject.accomplished }.by(1)
      end

      context "when it was the last series" do
        before do
          subject.accomplished = 2
        end

        it "moves to finished" do
          expect { subject.next! }.to change { subject.state }.to :finished
        end
      end
    end
  end

  describe "percentage" do
    it "is based on the current series" do
      subject.accomplished = 2
      subject.series = 2

      expect(subject.percentage).to eq 100

      subject.accomplished = 1
      subject.series = 2

      expect(subject.percentage).to eq 50
    end
  end
end
