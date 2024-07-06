class Variation < ApplicationRecord
  belongs_to :user, touch: true

  validates :value, presence: true
  validates :label, presence: true

  scope :from_today, -> (date) {
    where(%{
      (
        (? < variations.created_at + interval '1 day' AND ? > variations.created_at) OR variations.recurring = ?
      ) AND variations.base = ?
    }, date.end_of_day, date.end_of_day, true, false)
  }
  scope :from_this_month, -> (date) {
    where(%{
      variations.created_at > ? OR variations.recurring = ?
    }, date.beginning_of_month, true)
  }

  def daily_value(date)
    if self.recurring?
      value / date.end_of_month.day
    else
      value.to_f
    end
  end

  def monthly_value
    value
  end
end
