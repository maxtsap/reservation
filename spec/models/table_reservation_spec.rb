require 'spec_helper'

describe TableReservation do

  describe "#validations" do
    it { should validate_presence_of(:table_number) }
    it { should validate_presence_of(:started_at) }
    it { should validate_presence_of(:ended_at) }

    describe "#ended_at_greater_than_started_at" do
      let(:table_reservation) { build :table_reservation, table_number: 1, started_at: DateTime.current + 1.hour, ended_at: DateTime.current - 1.day }

      it "checks if end date is after start date" do
        expect(table_reservation).to_not be_valid
      end

      it "adds validation error message" do
        table_reservation.valid?
        expect(table_reservation.errors.full_messages).to be_eql ["Started at can't be greater than Ended at"]
      end
    end

    describe "#reservation_is_in_future" do
      let(:table_reservation) { build :table_reservation, table_number: 1, started_at: DateTime.current - 1.hour, ended_at: DateTime.current + 4.hours }

      it "checks if start date is in future" do
        expect(table_reservation).to_not be_valid
      end

      it "adds validation error message" do
        table_reservation.valid?
        expect(table_reservation.errors.full_messages).to be_eql ["Started at can't be in the past"]
      end
    end
  end

end
