class Player < ActiveRecord::Base
    after_initialize :default_values
    def default_values
        self.role ||= nil
        self.in_team ||= 0
        self.vote ||= nil
    end
    
    def self.set_team(gid, team)
       team.each do |seat|
           @player = Player.where(game_id: gid, seat_num: seat.to_i).take
           @player.in_team = 1
           @player.save
       end
    end
    
    def self.all_voted(gid)
        return Player.where(game_id: gid, vote: nil).count == 0
    end
    
    def self.all_done(gid)
        return Player.where(game_id: gid, in_team: 1, vote: nil).count == 0
    end
    
    def self.vote_result(gid)
        @game = Game.find(gid)
        return Player.where(game_id: gid, vote: 'pass').count > (@game.player_num / 2)
    end
    
    def self.clear_votes(gid)
        @player_ids = Player.where(game_id: gid).ids
        @player_ids.each do |id|
            @player = Player.find(id)
            @player.vote = nil
            @player.save
        end
    end
    
    def self.clear_team(gid)
        @player_ids = Player.where(game_id: gid, in_team: 1).ids
        @player_ids.each do |id|
            @player = Player.find(id)
            @player.in_team = 0
            @player.save
        end
    end
end
