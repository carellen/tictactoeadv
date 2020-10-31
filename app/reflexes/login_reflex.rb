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
    morph '#login', ApplicationController.render(
      partial: 'pages/login',
      locals: {
        login: element.dataset[:login],
        user: User.find(user[:id]),
        errors: nil,
      }
    )
  end

  def failure(response)
    @errors = response['error'] || response['errors']
  end

  def logout
    @user = nil
  end
end