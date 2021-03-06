require 'spec_helper'

describe TableReservation do

  shared_context "not valid" do

    it "is not valid" do
      expect(table_reservation).to_not be_valid
    end

    it "adds validation error message" do
      table_reservation.valid?
      expect(table_reservation.errors.full_messages).to be_eql error_message
    end

  end

  describe "#validations" do
    it { should validate_presence_of(:table_number) }
    it { should validate_presence_of(:started_at) }
    it { should validate_presence_of(:ended_at) }

    describe "#ended_at_greater_than_started_at" do
      let(:table_reservation) { build :table_reservation, table_number: 1, started_at: DateTime.current + 1.hour, ended_at: DateTime.current - 1.day }
      let(:error_message) { ["Started at can't be greater than Ended at"] }

      it_behaves_like "not valid"
    end

    describe "#reservation_is_in_future" do
      let(:table_reservation) { build :table_reservation, table_number: 1, started_at: DateTime.current - 1.hour, ended_at: DateTime.current + 4.hours }
      let(:error_message) { ["Started at can't be in the past"] }

      it_behaves_like "not valid"
    end

    describe "#reservation_overlapping" do

      context "when table is the same" do
        let!(:table_reservation1) { create :table_reservation, table_number: 1, started_at: DateTime.current + 10.hours, ended_at: DateTime.current + 14.hours }
        let(:table_reservation) { build :table_reservation, table_number: 1, started_at: started_at, ended_at: ended_at }
        let(:error_message) { ["Dates overlap existing reservations"] }

        context "when only end date overlaps" do
          let(:started_at) { DateTime.current + 5.hour }
          let(:ended_at) { DateTime.current + 11.hour }

          it_behaves_like "not valid"
        end

        context "when only start date overlaps" do
          let(:started_at) { DateTime.current + 11.hour }
          let(:ended_at) { DateTime.current + 15.hour }

          it_behaves_like "not valid"
        end

        context "when bound is greater than existing reservation" do
          let(:started_at) { DateTime.current + 9.hour }
          let(:ended_at) { DateTime.current + 15.hour }

          it_behaves_like "not valid"
        end
      end

      context "when table is different" do
        let!(:table_reservation) { create :table_reservation, table_number: 1, started_at: DateTime.current + 10.hours, ended_at: DateTime.current + 14.hours }
        let!(:table_reservation1) { build :table_reservation, table_number: 2, started_at: started_at, ended_at: ended_at }

        subject { table_reservation1 }

        context "when only end date overlaps" do
          let(:started_at) { DateTime.current + 5.hour }
          let(:ended_at) { DateTime.current + 11.hour }

          it { should be_valid }
        end

        context "when only start date overlaps" do
          let(:started_at) { DateTime.current + 11.hour }
          let(:ended_at) { DateTime.current + 15.hour }

          it { should be_valid }
        end

        context "when bound is greater than existing reservation" do
          let(:started_at) { DateTime.current + 9.hour }
          let(:ended_at) { DateTime.current + 15.hour }

          it { should be_valid }
        end
      end
    end
  end

  describe ".scopes" do
    let!(:table_reservation) { create :table_reservation, table_number: 1, started_at: DateTime.current + 10.hours, ended_at: DateTime.current + 14.hours }
    let!(:table_reservation1) { create :table_reservation, table_number: 1, started_at: DateTime.current + 1.hours, ended_at: DateTime.current + 4.hours }
    let!(:table_reservation2) { create :table_reservation, table_number: 2, started_at: DateTime.current + 1.hours, ended_at: DateTime.current + 4.hours }
    let!(:table_reservation3) { build :table_reservation, table_number: 1, started_at: DateTime.current + 1.hours, ended_at: DateTime.current + 4.hours }

    it "returns records with same table number" do
      expect(TableReservation.same_table(table_reservation1).to_a).to be_eql [table_reservation, table_reservation1]
    end

    it "returns overlapped records" do
      expect(TableReservation.overlapped(table_reservation3).to_a).to be_eql [table_reservation1, table_reservation2]
    end

    it "returns overlapped records without self" do
      expect(TableReservation.overlapped(table_reservation1).to_a).to be_eql [table_reservation2]
    end
  end

end
