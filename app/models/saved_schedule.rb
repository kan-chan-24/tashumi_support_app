class SavedSchedule < ApplicationRecord
  validates :pattern_key, presence: true
  validates :catchphrase, presence: true
  validates :schedule_data, presence: true
end
