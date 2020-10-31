class CounterReflex < StimulusReflex::Reflex
  delegate :current_user, to: :connection

  def increment
    @count = element.dataset[:count].to_i + element.dataset[:step].to_i
  end
  #
  # def toggle
  #   p element.dataset[:login]
  #   @login = !element.dataset[:login]
  # end
end