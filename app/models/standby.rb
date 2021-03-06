class Standby < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :date, presence: true, uniqueness: { scope: [:user_id] }, timeliness: { on_or_after: Time.zone.today }
end
