class CreateFreeTimes < ActiveRecord::Migration[8.1]
  def change
    create_table :free_times do |t|
      t.integer :day_of_week
      t.integer :minutes

      t.timestamps
    end
  end
end
