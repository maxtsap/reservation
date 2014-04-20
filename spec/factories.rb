FactoryGirl.define do

  factory :table_reservation do
    sequence(:table_number) { |n| n }
    started_at DateTime.current + 1.hours
    ended_at DateTime.current + 3.hours
  end

end
