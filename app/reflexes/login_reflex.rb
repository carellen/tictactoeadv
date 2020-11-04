class LoginReflex < StimulusReflex::Reflex

  def toggle
    morph '#login', ApplicationController.render(
      partial: 'pages/login',
      locals: {
        login: !element.dataset[:login],
        user: nil,
        errors: nil,
      }
    )
  end

  def success(user)
    current_user = User.find(user[:id])
    morph '#login', ApplicationController.render(
      partial: 'pages/login',
      locals: {
        login: element.dataset[:login],
        user: current_user,
        errors: nil,
      }
    )
  end

  def failure(response)
    @errors = response['error'] || response['errors']
  end

  def logout
    morph '#login', ApplicationController.render(
      partial: 'pages/login',
      locals: {
        login: element.dataset[:login],
        user: nil,
        errors: nil,
      }
    )
  end
end