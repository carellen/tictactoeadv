class CellComponent < ViewComponent::Base
  def initialize(cell:, game:, size:, mark: nil)
    @id = cell
    @game = game
    @size = size
    @mark = mark
    @color = @mark == 'x' ? 'red' : 'blue'
  end
end