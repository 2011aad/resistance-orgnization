class GamesController < ApplicationController
  
  def game_params
    params.require(:game).permit(:game_name, :player_num, :password)
  end
  
  def index
    session[:game_id] = nil
  end
  
  def create

  end
  
  def join_game
    @games = Game.all
  end
  
  def start_game
    if session[:game_id] == nil
      @game = Game.create!(game_params)
      session[:game_id] = @game.id
      session[:password] = @game.password
      @player = Player.create!({:game_id => @game.id})
      session[:player_id] = @player.id
    else
      if params[:game][:password] == Game.find(session[:game_id]).password
        @game = Game.find(session[:game_id])
        session[:password] = @game.password
        @player = Player.create!({:game_id => @game.id})
        session[:player_id] = @player.id
      else
        flash[:notice] = "Wrong Password!"
        redirect_to '/games/join_game'
        return 
      end
    end
    
    redirect_to '/games/waiting_to_start'
  end
  
  def waiting_to_start
    if session[:game_id] == nil || session[:password] == nil
      redirect_to '/games/index'
      return 
    end
    
    if session[:password] != (Game.find(session[:game_id])).password
      redirect_to '/games/join_game'
    end
    @game = Game.find(session[:game_id])
    
    if Game.full(@game.id)
      @game.game_status = 'play'
      # WebsocketRails[:channel].trigger(:refresh, nil)
      redirect_to '/games/play'
    end
  end
  
  def password
    session[:game_id] = params[:id]
  end
  
  def choose_seat
    @player_ids = Player.where(game_id: session[:game_id]).ids
    seats = []
    @player_ids.each do |player|
        @player = Player.find(player)
        seats.push(@player.seat_num)
    end
    if not seats.include?(params[:seat_number])
      @player = Player.find(session[:player_id])
      @player.seat_num = params[:seat_number]
      @player.save
    end
    redirect_to '/games/waiting_to_start'
  end
  
  def play
    @game = Game.find(session[:game_id])
    @player_ids = Player.where(game_id: @game.id).ids
    @myself = Player.find(session[:player_id])
    if @myself.role == nil
      spy_number = Game.spy_number(@game.player_num)
      @player_ids.shuffle!
      (@player_ids.first(spy_number)).each do |player_id|
        @player = Player.find(player_id)
        @player.role = "spy"
        @player.save
      end
      (@player_ids.last(@player_ids.length-spy_number)).each do |player_id|
        @player = Player.find(player_id)
        @player.role = "resistant"
        @player.save
      end
      @player_ids.shuffle!
      Game.set_sheriff(session[:game_id], @player_ids.first)
    end
    @game = Game.find(session[:game_id])
    @myself = Player.find(session[:player_id])
    @game_process = Game.game_process(session[:game_id])
    @spy_ids = Player.where(game_id: session[:game_id], role: 'spy').ids
    @teammates = []
    @spy_ids.each do |id|
      if id != session[:player_id]
        @teammates.push(Player.find(id).seat_num)
      end
    end
    
    if @game.game_status == 'voting'
      redirect_to '/games/voting'
    end
  end
    
  def choose_team_member
    @game = Game.find(session[:game_id])
    @team_size = Game.team_size(@game.id)
  end
  
  def team_info
    @team = params[:team].select{|k,v| v=='1'}.keys
    Player.set_team(session[:game_id], @team)
    @game = Game.find(session[:game_id])
    @game.game_status = 'voting'
    @game.save
    redirect_to '/games/voting'
  end
  
  def voting
    @game = Game.find(session[:game_id])
    if @game.game_status == 'play'
      redirect_to '/games/play'
    elsif @game.game_status == 'tasking'
      redirect_to '/games/tasking'
    else
    end
  end
  
  def collect_votes
    @player = Player.find(session[:player_id])
    if params[:commit] == 'Accept'
      @player.vote = 'pass'
      @player.save
    else
      @player.vote = 'not_pass'
      @player.save
    end
    @game = Game.find(session[:game_id])
    if Player.all_voted(session[:game_id])
      if Player.vote_result(session[:game_id])
        @game.game_status = 'tasking'
        @game.save
        redirect_to '/games/tasking'
      else
        @game.game_status = 'play'
        @game.save
        Player.clear_team(session[:game_id])
        redirect_to '/games/play'
      end
      Player.clear_votes(session[:game_id])
      Game.move_sheriff(session[:game_id])
    else
      redirect_to '/games/voting'
    end
  end
  
  def tasking
    @player = Player.find(session[:player_id])
    if @player.in_team == 0
      redirect_to '/games/waiting'
    end
    
    @game = Game.find(session[:game_id])
    if @game.game_status == 'play'
      redirect_to '/games/play'
    elsif @game.game_status == 'finish'
      if Game.who_wins(@game.id) == 'spy'
          redirect_to '/games/spy_win'
      else
          redirect_to '/games/resistant_win'
      end
    else
    end
  end
  
  def waiting
    @game = Game.find(session[:game_id])
    if @game.game_status == 'play'
      redirect_to '/games/play'
    elsif @game.game_status == 'finish'
      if Game.who_wins(@game.id) == 'spy'
          redirect_to '/games/spy_win'
      elsif Game.who_wins(@game.id) == 'resistant'
          redirect_to '/games/resistant_win'
      end
    else
    end
  end
  
  def collect_tasks
    @player = Player.find(session[:player_id])
    if params[:commit] == 'Success'
      @player.vote = 'pass'
      @player.save
    else
      @player.vote = 'not_pass'
      @player.save
    end
    @game = Game.find(session[:game_id])
    if Player.all_done(@game.id)
      Game.update_game_process(@game.id)
      if Game.is_finish(@game.id)
        @game.game_status = 'finish'
        @game.save
        if Game.who_wins(@game.id) == 'spy'
          redirect_to '/games/spy_win'
        elsif Game.who_wins(@game.id) == 'resistant'
          redirect_to '/games/resistant_win'
        end
      else
        @game.game_status = 'play'
        @game.save
        redirect_to '/games/play'
      end
      Player.clear_votes(session[:game_id])
      Player.clear_team(session[:game_id])
    else
      redirect_to '/games/tasking'
      return
    end
  end
  
  def resistant_win
    if session[:game_id] == nil
      redirect_to 'games/index'
    end
  end
  
  def spy_win
    if session[:game_id] == nil
      redirect_to 'games/index'
    end
  end
  
  def restart
    @game = Game.find(session[:game_id])
    if @game.game_status == 'finish'
      Game.restart(session[:game_id])
    end
    redirect_to '/games/play'
  end

end
