class FieldComponent < ViewComponent::Base
  def initialize(game: nil, cells: nil, size: nil)
    @game = game
    @cells = cells
    @size = size
  end
end