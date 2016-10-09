class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :player_num
      t.string :password
      t.string :game_process
      t.integer :sheriff_player_id
      t.string :game_status

      t.timestamps null: false
    end
  end
end
