require 'spec_helper'

describe TableReservation do

  describe "#validations" do
    it { should validate_presence_of(:table_number) }
    it { should validate_presence_of(:started_at) }
    it { should validate_presence_of(:ended_at) }
  end

end
