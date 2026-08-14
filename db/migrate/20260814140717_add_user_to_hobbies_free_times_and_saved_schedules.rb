class AddUserToHobbiesFreeTimesAndSavedSchedules < ActiveRecord::Migration[8.1]
  def change
    add_reference :hobbies, :user, null: false, foreign_key: true
    add_reference :free_times, :user, null: false, foreign_key: true
    add_reference :saved_schedules, :user, null: false, foreign_key: true
  end
end
