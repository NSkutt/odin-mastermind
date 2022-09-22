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

# creates the player, takes guesses, gives them to the Codemaster
class Player
  def initialize
    @name = gets.chomp
    @error = false
    @codemaster = Codemaster.new
  end

  def input
    msg = @error ? 'Invalid entry! Try again' : "What's your guess? (Please give 4 numbers 1 - 6)"
    p msg
    @error = false
    input = gets.chomp
    @guess = input.chars
    @guess.delete_if { |guess| guess == ' ' }
    @guess.each_with_index { |item, idx| @guess[idx] = item.to_i }
    check_errors(@guess)
    @codemaster.check_code(@guess)
  end

  def check_errors(code)
    error unless code.is_a?(Array) && code.length == 4
    error unless code.each { |guess| guess < 7 && guess.positive? }
  end

  def error
    @error = true
    input
  end
end

_game = Player.new
