# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


games = [
    {:game_name => 'game1', :player_num => 5, :password => 'game1', :status => 'waiting'},
    {:game_name => 'game2', :player_num => 6, :password => 'game2', :status => 'waiting'},
    {:game_name => 'game3', :player_num => 9, :password => 'game3', :status => 'waiting'},
    {:game_name => 'game4', :player_num => 7, :password => 'game4', :status => 'waiting'},
    {:game_name => 'game5', :player_num => 8, :password => 'game5', :status => 'waiting'},
    {:game_name => 'game6', :player_num => 6, :password => 'game6', :status => 'waiting'},
    ]
    
games.each do |game|
    Game.create!(game)
end