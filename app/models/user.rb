class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :hobbies, dependent: :destroy
  has_many :free_times, dependent: :destroy
  has_one :saved_schedule, dependent: :destroy

  normalizes :nickname, with: ->(n) { n.strip }
end
