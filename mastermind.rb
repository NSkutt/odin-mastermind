# frozen_string_literal: true

# Creates, contains, and checks against, the code
class Codemaster
  def initialize
    @choices = Array.new(4) { [1, 2, 3, 4, 5, 6] }
    set_code
  end

  def check_code(guess)
    victory if guess == @code
    blackpegs(guess)
  end

  def blackpegs(guess)
    @black = 0
    i = 0
    while i < @code.length
      next unless @code[i] == guess[i]

      @black += 1
      guess[i] = 0
    end
    whitepegs(guess)
  end

  def whitepegs(guess)
    @white = 0
    i = 0
    while i < @code.length
      next unless @code.include?(guess[i])

      @white += 1
    end
    p "Black: #{@black}, White: #{@white}"
  end

  private

  def set_code
    @code = @choices.flatten.sample(4)
  end
end

_game = Codemaster.new
