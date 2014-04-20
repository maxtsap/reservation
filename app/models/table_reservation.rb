class TableReservation < ActiveRecord::Base

  validates :table_number, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true

  validate :ended_at_greater_than_started_at

  private

  def ended_at_greater_than_started_at
    if self.started_at && (self.started_at > self.ended_at)
      self.errors.add(:started_at, "can't be greater than Ended at")
    end
  end

end
