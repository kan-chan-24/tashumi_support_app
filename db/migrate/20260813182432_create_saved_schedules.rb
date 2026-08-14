class CreateSavedSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :saved_schedules do |t|
      t.string :pattern_key, null: false
      t.string :catchphrase, null: false
      t.json :schedule_data, null: false

      t.timestamps
    end
  end
end
