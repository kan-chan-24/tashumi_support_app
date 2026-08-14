class SavedSchedule < ApplicationRecord
  belongs_to :user

  validates :pattern_key, presence: true
  validates :catchphrase, presence: true
  validates :schedule_data, presence: true
end
