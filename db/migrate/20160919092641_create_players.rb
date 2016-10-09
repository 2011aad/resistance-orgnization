class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :role
      t.references :game, index: true
      t.integer :in_team
      t.integer :seat_num
      t.string :vote

      t.timestamps null: false
    end
  end
end
