# frozen_string_literal: true

# Creates, contains, and checks against, the code
class Codemaster
  attr_reader :victory, :choices

  def initialize
    @choices = (1..6).to_a
    set_code
  end

  def check_code(guess, computer)
    return @victory = true if guess == @code

    blackpegs(guess, computer)
  end

  def blackpegs(guess, computer)
    @black = 0
    i = -1
    arr = []
    while i < (@code.length - 1)
      i += 1
      arr.push(@code[i])
      next unless @code[i] == guess[i]

      @black += 1
      guess[i] = computer == false ? 0 : { i.to_s.to_sym => arr[i] }
      arr[i] = 'x'
    end
    whitepegs(guess, arr, computer)
  end

  def whitepegs(guess, code, computer)
    @white = 0
    i = -1
    while i < (guess.length - 1)
      i += 1
      next unless code.include?(guess[i])

      @white += 1
      code.delete_at(code.index(guess[i]))
    end
    p "Black: #{@black}, White: #{@white}"
    return guess if computer == true
  end

  def code2(code)
    @code = code.to_i.digits.reverse
  end

  private

  def set_code
    @code = []
    4.times { @code.push(@choices.sample) }
  end
end

# creates the player, takes guesses, gives them to the Codemaster
class Player
  def initialize
    @maker = false
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
    @maker = true
    p 'What is your code?'
    code = gets.chomp
    @codemaster.code2(code)
    @comp = Ai.new
    guessing(@comp.ans)
  end

  def guessing(ease, info = [])
    # p info
    options = @codemaster.choices
    pegs = thingamajig(info)
    if ease == 'hard'
      guess = @comp.hard(options, pegs)
    else
      med = @comp.ans == 'EASY'
      guess = @comp.easy(options, pegs)
    end
    pegs = play(guess)
  end

  def thingamajig(pegs)
    blackpegs = {}
    whitepegs = {}
    pegs.each do |peg|
      blackpegs.update(peg) if peg.is_a?(Hash)
    end

    feedback([blackpegs, whitepegs])
  end

  def feedback(pegs)
    guess = Array.new(4)
    pegs[0].each_pair { |idx, val| guess[idx.to_s.to_i] = val }
    guess
    # Figure out medium later
  end

  # ------ Blank Line Separator ------

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
    if @count > 10
      @maker == false ? victory('loss') : victory(@name)
    end
    results = @codemaster.check_code(code, @maker)
    if @codemaster.victory == true
      @maker == false ? victory(@name) : victory('loss')
    end
    @count += 1
    @maker == false ? input : guessing(@comp.ans, results)
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

# This is the AI for if the player wishes to make the code
class Ai
  attr_reader :ans

  def initialize
    p 'Would you like to play against the Easy or the Hard AI?'
    @ans = gets.chomp.upcase
  end

  def easy(opt, pegs)
    i = (4 - pegs.compact.length)
    guess = pegs
    while i.positive?
      idx = pegs.find_index(nil)
      guess[idx] = opt.sample
      i -= 1
    end
    guess
  end
end

_game = Player.new
