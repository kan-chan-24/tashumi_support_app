class CreateHobbies < ActiveRecord::Migration[8.1]
  def change
    create_table :hobbies do |t|    
      # 趣味の名前
      t.string :name, null:false
      # 趣味の割合
      t.integer :percentage, null:false

      t.timestamps
    end
  end
end
