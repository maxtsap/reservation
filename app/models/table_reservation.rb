class TableReservation < ActiveRecord::Base

  validates :table_number, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true

end
