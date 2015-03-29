class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name
      t.string :id_number
      t.string :addres

      t.timestamps null: false
    end
  end
end
