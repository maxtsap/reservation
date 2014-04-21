class TableReservation < ActiveRecord::Base

  validates :table_number, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true

  validate :ended_at_greater_than_started_at
  validate :reservation_is_in_future
  validate :reservation_overlapping

  scope :same_table, -> (table_reservation) { where("table_number = ?", table_reservation.table_number) }
  scope :overlapped, -> (table_reservation) { where.not(id: table_reservation.id).
                                              where("(:started_at >= started_at AND :started_at < ended_at) OR
                                                     (:ended_at > started_at AND :ended_at < ended_at) OR
                                                     (:started_at <= started_at AND :ended_at >= ended_at)",
                                                     {ended_at: table_reservation.ended_at,
                                                      started_at: table_reservation.started_at}) }

  private

  def ended_at_greater_than_started_at
    if dates_present? && (self.started_at > self.ended_at)
      self.errors.add(:started_at, "can't be greater than Ended at")
    end
  end

  def reservation_is_in_future
    if dates_present? && (self.started_at < DateTime.current)
      self.errors.add(:started_at, "can't be in the past")
    end
  end

  def reservation_overlapping
    self.errors.add(:base, "Dates overlap existing reservations") if overlaps?
  end

  def overlaps?
    dates_present? && TableReservation.same_table(self).overlapped(self).any?
  end

  def dates_present?
    self.started_at.present? && self.ended_at.present?
  end

end
