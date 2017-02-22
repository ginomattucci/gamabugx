desc "This task is called by the Heroku scheduler add-on"
task :check_best_guess_winners => :environment do
  puts "Going through BestGuess for winners"
  BestGuess.where(winner: nil).where('ends_at <= ?', Time.now).each do |best_guess|
    print "Checking '#{best_guess.title}' - "
    if best_guess.check_winner
      print "Winner: #{best_guess.winner.username}"
    else
      print "No winner"
    end
    puts
  end
  puts "Done"
end

