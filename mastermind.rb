# frozen_string_literal: true

# Creates, contains, and checks against, the code
class Codemaster
  attr_reader :victory, :choices

  def initialize
    @choices = Array.new(4) { [1, 2, 3, 4, 5, 6] }
    set_code
  end

  def check_code(guess)
    p guess
    return @victory = true if guess == @code

    blackpegs(guess)
  end

  def blackpegs(guess)
    @black = 0
    i = -1
    arr = []
    while i < (@code.length - 1)
      i += 1
      arr.push(@code[i])
      next unless @code[i] == guess[i]

      @black += 1
      guess[i] = 0
      arr[i] = 'x'
    end
    whitepegs(guess, arr)
  end

  def whitepegs(guess, code)
    @white = 0
    i = -1
    while i < (guess.length - 1)
      i += 1
      next unless code.include?(guess[i])

      @white += 1
      code.delete_at(code.index(guess[i]))
    end
    p "Black: #{@black}, White: #{@white}"
  end

  def code2(code)
    @code = code
  end

  private

  def set_code
    @code = @choices.flatten.sample(4)
  end
end

# creates the player, takes guesses, gives them to the Codemaster
class Player
  def initialize
    p 'Name for player?'
    @name = gets.chomp
    @error = false
    @codemaster = Codemaster.new
    @count = 1
    code_or_play
  end

  def code_or_play
    p 'Would you like to make the code (1) or guess the code (2)'
    choice = gets.chomp
    case choice
    when '1'
      make_code
    when '2'
      input
    else
      p 'Invalid choice! Exiting...'
    end
  end

  def make_code
    p 'What is your code?'
    code = gets.chomp
    @codemaster.code2(code)
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
    play(@guess)
  end

  def check_errors(code)
    error unless code.is_a?(Array) && code.length == 4
    code.each do |guess|
      if guess > @codemaster.choices.flatten.last
        error
      elsif @codemaster.choices.flatten.include?(guess) != true
        error
      end
    end
  end

  def error
    @error = true
    input
  end

  def play(code)
    victory('loss') if @count > 10
    @codemaster.check_code(code)
    victory(@name) if @codemaster.victory == true
    @count += 1
    input
  end

  def victory(condition)
    msg = condition == @name ? "Congratulations #{@name} you win!" : 'You lose, better luck next time'
    p msg
    p 'Would you like to play again?'
    p 'Yes/No'
    ans = gets.chomp
    ans.upcase == 'YES' ? _again = Player.new : exit
  end
end

_game = Player.new
