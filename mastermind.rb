# frozen_string_literal: true

# Creates, contains, and checks against, the code
class Codemaster
  def initialize
    @choices = Array.new(4) { [1, 2, 3, 4, 5, 6] }
    set_code
  end

  private

  def set_code
    @code = @choices.flatten.sample(4)
  end
end

_game = Codemaster.new
