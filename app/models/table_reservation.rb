class TableReservation < ActiveRecord::Base

  validates :table_number, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true

  validate :ended_at_greater_than_started_at
  validate :reservation_is_in_future
  validate :reservation_overlapping

  private

  def ended_at_greater_than_started_at
    if self.started_at && (self.started_at > self.ended_at)
      self.errors.add(:started_at, "can't be greater than Ended at")
    end
  end

  def reservation_is_in_future
    if self.started_at && (self.started_at < DateTime.current)
      self.errors.add(:started_at, "can't be in the past")
    end
  end

  def reservation_overlapping
    self.errors.add(:base, "Dates overlap existing reservations") if overlaps?
  end

  def overlaps?
    self.started_at.present? && self.ended_at.present? && TableReservation.where("table_number = ?", self.table_number).
                     where("(:started_at >= started_at AND :started_at < ended_at) OR
                            (:ended_at > started_at AND :ended_at < ended_at) OR
                            (:started_at <= started_at AND :ended_at >= ended_at)",
            {ended_at: self.ended_at.to_s(:db), started_at: self.started_at.to_s(:db)}).any?
  end

end
