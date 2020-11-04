class GameReflex < StimulusReflex::Reflex
  delegate :current_user, to: :connection

  def create
    game = Game.create(params.permit(:size, :title))
    if current_user.is_a? User
      game.players << current_user
      game.update(rating: true)
    else
      Rails.cache.write("game:#{game.id}:#{Matchup.marks.keys.sample}_player", user_id)
    end
    Rails.cache.write("game:#{user_id}:active", game)
    Rails.cache.write("game:#{game.id}:x_winnables", game.win_list)
    Rails.cache.write("game:#{game.id}:o_winnables", game.win_list)
    Rails.cache.write("game:#{game.id}:turns", [])

    morph '#gameForm', ApplicationController.render(GameFormComponent.new(game_id: game.id, message: 'Waiting for opponent...'))
    morph'#field', ApplicationController.render(FieldComponent.new(game: game))
    cable_ready['game_list'].morph(
      selector: '#gameList',
      html: ApplicationController.render(GameListComponent.new)
    )
    cable_ready.broadcast
  end

  def join
    morph :nothing
    game = Game.find(element.dataset[:id])

    return if Rails.cache.fetch("game:#{user_id}:active") == game

    if game.in_progress?
      cable_ready[GameChannel].morph(selector: '#field', html: ApplicationController.render(FieldComponent.new(game: game)))
      cable_ready.broadcast_to(game)
    else
      add_second_player(game)

      cable_ready['game_list'].morph(
        selector: '#gameList',
        html: ApplicationController.render(GameListComponent.new)
      )
      cable_ready.broadcast
      %w(x o).each do |mark|
        player = Rails.cache.fetch("game:#{game.id}:#{mark}_player")
        color = mark == 'x' ? 'red' : 'blue'
        message = "You play for <span class='text-2xl text-#{color}-700'>#{mark}</span>".html_safe
        cable_ready["StimulusReflex::Channel:#{player}"].morph(
          selector: '#gameForm',
          html: ApplicationController.render(GameFormComponent.new(game_id: game.id, message: message))
        )
        cable_ready.broadcast
      end
      cable_ready[GameChannel].morph(selector: '#game', html: ApplicationController.render(GameComponent.new(player: 'x')))
      cable_ready[GameChannel].morph(selector: '#field', html: ApplicationController.render(FieldComponent.new(game: game)))
      cable_ready.broadcast_to(game)
    end
  end

  def check
    morph :nothing
    game_id = element.dataset[:game]

    return if is_watcher?(game_id) || element.dataset[:checked]

    player = Rails.cache.fetch("actual_player:#{game_id}") { 'x' }

    # check if it's current user turn
    return unless user_id == Rails.cache.fetch("game:#{game_id}:#{player}_player")

    next_player = player == 'x' ? 'o' : 'x'
    Rails.cache.write("actual_player:#{game_id}", next_player)

    update_turns(game_id, player, element.id)
    update_winnable_list(game_id, player, element.id)

    winner = check_winner(game_id, player)
    draw = !winnable?(game_id)

    game = Game.find(game_id)

    cable_ready[GameChannel].outer_html(
      selector: "##{element.id}",
      html: ApplicationController.render(CellComponent.new(
        cell: element.id,
        game: game_id,
        mark: player,
        size: element.dataset[:size].to_i
        )
      )
    )

    if winner || draw
      %w(x o).each do |mark|
        player_id = Rails.cache.fetch("game:#{game.id}:#{mark}_player")
        message = if winner
                    "You #{mark == player ? 'win &#128578;' : 'lose &#128577;'}".html_safe
                  else
                    'draw &#128533'.html_safe
                  end
        cable_ready["StimulusReflex::Channel:#{player_id}"].morph(
          selector: '#game',
          html: ApplicationController.render(GameComponent.new(player: mark, message: message))
        )
        cable_ready.broadcast
      end
    else
      cable_ready[GameChannel].morph(
        selector: '#game',
        html: ApplicationController.render(GameComponent.new(player: next_player)
        )
      )
      cable_ready.broadcast_to(game)
    end

    finish_game(game, player) if winner
    finish_game(game, nil) if draw
  end

  def add_second_player(game)
    if current_user.is_a? User
      game.players << current_user
      game.matchups.pluck(:mark, :user_id).each do |mark, user_id|
        Rails.cache.write("game:#{game.id}:#{mark}_player", user_id)
      end
    else
      if Rails.cache.fetch("game:#{game.id}:x_player")
        Rails.cache.write("game:#{game.id}:o_player", user_id)
      else
        Rails.cache.write("game:#{game.id}:x_player", user_id)
      end
    end
    game.update(status: :in_progress)
    Rails.cache.write("game:#{user_id}:active", game)
  end

  def update_turns(game_id, player, move)
    turns = Rails.cache.fetch("game:#{game_id}:turns")
    turns << "#{player}_#{move}"
    Rails.cache.write("game:#{game_id}:turns", turns)
  end

  def update_winnable_list(game_id, player, move)
    opp = player == 'x' ? 'o' : 'x'
    win_list = Rails.cache.fetch("game:#{game_id}:#{opp}_winnables")
    win_list.reject! { |comb| comb.include? move }
    Rails.cache.write("game:#{game_id}:#{opp}_winnables", win_list)
  end

  def winnable?(game_id)
    Rails.cache.fetch("game:#{game_id}:x_winnables").size > 0 || Rails.cache.fetch("game:#{game_id}:o_winnables").size > 0
  end

  def is_watcher?(game_id)
    user_id != Rails.cache.fetch("game:#{game_id}:x_player") && user_id != Rails.cache.fetch("game:#{game_id}:o_player")
  end

  def check_winner(game_id, player)
    player_moves = Rails.cache.fetch("game:#{game_id}:turns").map do |move|
      p, m = move.split('_')
      m if p == player
    end.compact

    return false if player_moves.size < 5

    win_list = Rails.cache.fetch("game:#{game_id}:#{player}_winnables")
    win_list.any? { |arr| arr.all? { |move| move.in? player_moves }}
  end

  def finish_game(game, winner)
    morph :nothing
    if game.rating
      game.update(status: :finished, winner: winner && current_user, turns: Rails.cache.fetch("game:#{game.id}:turns"))
      if winner
        current_user.update(rating: current_user.rating + 2)
      else
        %w(x o).each do |mark|
          id = Rails.cache.fetch("game:#{game.id}:#{mark}_player")
          user = User.find(id)
          user.update(rating: user.rating + 1)
        end
      end
      cable_ready['rating'].morph(
        selector: '#rating',
        html: ApplicationController.render(RatingComponent.new)
      )
      cable_ready.broadcast
    end

    cable_ready[GameChannel].morph(
      selector: '#gameForm',
      html: ApplicationController.render(GameFormComponent.new)
    )
    cable_ready.broadcast_to(game)
    cable_ready[GameChannel].morph(
      selector: '#field',
      html: ApplicationController.render(FieldComponent.new)
    )
    cable_ready.broadcast_to(game)

    clean_up(game)
  end

  def adjust_preview
    size = Game.cell_size(element.value.to_i)
    cells =  Array.new(element.value.to_i) {Array.new(element.value.to_i)}
    morph '#field', ApplicationController.render(
      FieldComponent.new(cells: cells, size: size)
    )
  end

  def user_id
    @user_id ||= current_user.is_a?(User) ? current_user.id : current_user
  end

  def clean_up(game)
    morph :nothing
    game_id = game.id
    x = Rails.cache.fetch("game:#{game_id}:x_player")
    o = Rails.cache.fetch("game:#{game_id}:o_player")

    Rails.cache.delete("game:#{x}:active")
    Rails.cache.delete("game:#{o}:active")
    Rails.cache.delete("actual_player:#{game_id}")
    Rails.cache.delete("game:#{game_id}:x_player")
    Rails.cache.delete("game:#{game_id}:o_player")
    Rails.cache.delete("game:#{game_id}:x_winnables")
    Rails.cache.delete("game:#{game_id}:o_winnables")
    Rails.cache.delete("game:#{game_id}:turns")

    game.delete unless game.rating

    cable_ready['game_list'].morph(
      selector: '#gameList',
      html: ApplicationController.render(GameListComponent.new)
    )
    cable_ready.broadcast
  end
end