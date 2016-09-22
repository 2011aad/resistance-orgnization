class Game < ActiveRecord::Base
    @table = [[2,3,2,3,3],
              [2,3,4,3,4],
              [2,3,3,4,4],
              [3,4,4,5,5],
              [3,4,4,5,5],
              [3,4,4,5,5],
             ]
    
    after_initialize :default_values
    def default_values
        self.game_process ||= 'undefined,undefined,undefined,undefined,undefined'
        self.game_status ||= 'play'
    end
    
    def self.full(gid)
        @player_ids = Player.where(game_id: gid).ids
        @seats = []
        @player_ids.each do |player|
            @player = Player.find(player)
            @seats.push(@player.seat_num)
        end
        @game = Game.find(gid)
        (1..@game.player_num).each do |x|
            if not @seats.include?(x)
                return false
            end
        end
        return true
    end
    
    def self.game_process(game_id)
        @game = Game.find(game_id)
        return (@game.game_process).split(',')
    end
    
    def self.spy_number(player_number)
        l = [1,1,1,2,2,3,3,3,4]
        return l[player_number-2]
    end
    
    def self.team_size(gid)
        @game = Game.find(gid)
        if @game.player_num < 5
            return 1
        else
            return @table[@game.player_num-5][Game.round_num(gid)]
        end
    end
    
    def self.round_num(gid)
        @game = Game.find(gid)
        pro = @game.game_process.split(',')
        return pro.index('undefined')
    end
    
    def self.set_sheriff(game_id, sheriff_id)
        @game = Game.find(game_id)
        @game.sheriff_player_id = sheriff_id
        @game.save
    end
    
    def self.move_sheriff(gid)
        @game = Game.find(gid)
        @player_ids = Player.where(game_id: gid).ids
        index = (@player_ids.index(@game.sheriff_player_id) + 1) % (@player_ids.length)
        @game.sheriff_player_id = @player_ids[index]
        @game.save
    end
    
    def self.update_game_process(gid)
        @game = Game.find(gid)
        pro = @game.game_process.split(',')
        index = pro.index('undefined')
        min_fail = (@game.player_num>=7 and Game.round_num(gid)==3)? 2:1
        if Player.where(game_id: gid, vote: 'not_pass').count >= min_fail
            pro[index] = 'fail'
        else
            pro[index] = 'success'
        end
        @game.game_process = pro.join(',')
        @game.save
    end
    
    def self.is_finish(gid)
        @game = Game.find(gid)
        pro = @game.game_process.split(',')
        return pro.count('fail') == 3 || pro.count('success') == 3
    end
    
    def self.who_wins(gid)
        @game = Game.find(gid)
        pro = @game.game_process.split(',')
        if pro.count('fail') == 3
            return 'spy'
        elsif pro.count('success') == 3
            return 'resistant'
        else
            return nil
        end
    end
    
    def self.restart(gid)
        @game = Game.find(gid)
        @game.game_process = 'undefined,undefined,undefined,undefined,undefined'
        @game.game_status = 'play'
        @player_ids = Player.where(game_id: gid).ids
        @player_ids.each do |id|
            @player = Player.find(id)
            @player.role = nil
            @player.save
        end
        @game.save
    end
end
