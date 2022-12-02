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
    check = []
    while i < (@code.length - 1)
      i += 1
      check.push(@code[i])
      next unless @code[i] == guess[i]

      @black += 1
      guess[i] = computer == false ? 0 : { i.to_s.to_sym => check[i] }
      check[i] = 'x'
    end
    whitepegs(guess, check, computer)
  end

  def whitepegs(guess, code, computer)
    @white = 0
    i = -1
    while i < (guess.length - 1)
      i += 1
      next unless code.include?(guess[i])

      @white += 1
      code.delete_at(code.index(guess[i]))
      guess[i] = [guess[i]]
    end
    p "Black: #{@black}, White: #{@white}"
    return guess if computer == true
  end

  def code2(code)
    @code = code
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
      make_code(@codemaster.choices)
    when '2'
      input
    else
      p 'Invalid choice! Exiting...'
    end
  end

  def make_code(options)
    @maker = true
    msg = @error == false ? 'What is your code?' : 'Invalid Entry, please try again.'
    p msg
    code = gets.chomp.to_i.digits.reverse
    check_errors(code)
    @codemaster.code2(code)
    @comp = Ai.new(options)
    guessing(@comp.ans)
  end

  def guessing(ease, info = [])
    options = @codemaster.choices
    pegs = peg_check(info)
    guess = ease == 'HARD' ? pegs : @comp.easy(options, pegs)
    play(guess)
  end

  def peg_check(pegs)
    blackpegs = {}
    whitepegs = []
    pegs.each do |peg|
      blackpegs.update(peg) if peg.is_a?(Hash)
      whitepegs.push(peg.first) if peg.is_a?(Array)
    end
    if @comp.ans == 'HARD'
      @comp.hard(@count, pegs, blackpegs.length, whitepegs.length)
    else
      feedback([blackpegs, whitepegs])
    end
  end

  def feedback(pegs)
    guess = Array.new(4)
    pegs[0].each_pair { |idx, val| guess[idx.to_s.to_i] = val }
    guess.each_index do |idx|
      next unless guess[idx].nil?
      next unless pegs[1].empty? == false

      guess[idx] = pegs[1].sample
      used = pegs[1].find_index(guess[idx])
      pegs[1].delete_at(used)
    end
    guess
  end

  # ------ Code Making above Code breaking below ------

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
    @maker == false ? input : make_code
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
    ans.upcase == 'YES' ? Player.new : exit
  end
end

# This is the AI for if the player wishes to make the code
class Ai
  attr_reader :ans

  def initialize(options)
    p 'Would you like to play against the Easy or the Hard AI?'
    @ans = gets.chomp.upcase
    return unless @ans == 'HARD'

# Create the set S of 1,296 possible codes {1111, 1112, ... 6665, 6666}. Step 1
    @s = []
    options.repeated_permutation(4) { |combo| @s.push(combo) }
  end

  def easy(opt, pegs)
    i = (4 - pegs.compact.length)
    guess = pegs
    while i.positive?
      idx = pegs.find_index(nil)
      guess[idx] = opt.sample
      i -= 1
    end
    p guess
    guess
  end

  # --- Line separating EASY from HARD ---

  def hard(count, prev, blackpegs, whitepegs)
    return [1, 1, 2, 2] if count == 1

    prev.each_with_index do |item, idx|
      prev[idx] = item.values[0] if item.is_a?(Hash)
      prev[idx] = item[0] if item.is_a?(Array)
    end
    @s.delete(prev)
    decipherbp(prev, blackpegs, whitepegs)
    minmax_setup((blackpegs + whitepegs))
  end

  def decipherbp(prev, bkp, wtp)
    base_set = prev + ['\d']
    keep = []
    base_set.permutation(bkp) { |perm| keep.push(perm) }
    cleanbp(keep, prev, (bkp + wtp))
  end

  def cleanbp(perms, prev, wtp)
    keeping = []
    perms.each do |code|
      reducer = code.join
      @s.each do |poss|
        keeping.push(poss) if /#{reducer}/.match?(poss.join)
      end
    end
    @s = keeping
    decipherwp(prev, wtp)
  end

  def decipherwp(prev, wtp)
    keep = []
    merger = {}
    prev.combination(wtp) { |combo| keep.push(combo) }
    idx = keep.first.length <=> 2
    iter = 0
    return edge_case(prev, wtp) if wtp < 1 || wtp > 3

    cleanwp(keep, merger, idx, iter)
  end

  def edge_case(prev, wtp)
    if wtp < 1
      prev.each { |num| @s.delete_if { |set| set.include?(num) } }
    elsif wtp > 3
      @s.delete_if { |set| set.sort != prev.sort }
      @s.uniq!
    else
      p 'Error!? Less than 1 and more than 1, more than 3 and less than 3'
    end
    @s
  end

  def cleanwp(keep, merger, idx, iter)
    keep.each do |arr|
      keeping = []
      @s.each_index do |code|
        next unless @s[code].count(arr.first) >= arr.count(arr.first) &&
                    @s[code].count(arr[idx]) >= arr.count(arr[idx]) &&
                    @s[code].count(arr.last) >= arr.count(arr.last)

        keeping.push(@s[code])
      end
      merger.store("set#{iter}".to_sym, keeping)
      iter += 1
    end
    @s = merger.values.flatten(1).uniq
  end

  def minmax_setup(pegs)
    i = 0
    hsh = {}
    arr = @s.to_s
    set = []
    (1..6).to_a.repeated_permutation(4) { |perm| set.push(perm) }
    scores = minmax(i, hsh, arr, set, pegs)

    exit
  end

  def minmax(iter, scores, save, set, pegs)
    set.each do |perm|
      limit = 5
      wtp = 0
      while wtp < limit
        scores["s#{iter}:#{wtp}".to_sym] = decipherwp(perm, wtp).length
        # p "s#{iter}:#{wtp} : #{scores["s#{iter}:#{wtp}".to_sym]}"
        @s = arrayify(save.chars)
        wtp += 1
      end
      iter += 1
    end
    pessimism(scores)
  end

  def arrayify(arr)
    arr.each do |elem|
      if elem == '['
        arr.push([])
      elsif elem.is_a?(Array)
        break
      elsif elem.to_i.positive?
        arr.last.push(elem.to_i)
      else
        next
      end
    end
    arr.delete_if { |char| char.is_a?(String) }
    arr.uniq!
    arr
  end

  def pessimism(scores)
    ans_sheet = []
    scores.each_slice(5) do |batch|
      x = batch.transpose[1].max
      batch.each { |arr| ans_sheet.push(arr) if arr.include?(x) }
    end
    ans_sheet.delete_if { |arr| arr.include?(0) }
    y = ans_sheet.transpose[1].min
    ans_sheet.each { |arr| p arr if arr.include?(y) }
  end
end

Player.new
