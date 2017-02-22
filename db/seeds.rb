# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

puts "- Creating plans"
plan = nil
6.times do |i|
  plan = Plan.create!(price: 100 + i, credits: 49 + i, title: "Plano #{i}")
end
puts "<-- Plans created -->"

puts "<-- Creating Users -->"
10.times do |index|
  index += 1
  user = User.new(username: "user#{index}", email: "user_#{index}@test.com", password:'123123123', credits: 10_000, birthday: 29.years.ago)
  puts "Creating #{user.username}"
  user.save!
  purchase = Purchase.create!(user: user,
                              invoice: SecureRandom.hex,
                              invoice_url: 'http://lvh.me:3000/',
                              payment_method: 'bank_slip',
                              plan: plan,
                              plan_credits: plan.credits,
                              plan_name: plan.title,
                              plan_price: plan.price,
                              status: ['pending', 'paid', 'expired'].sample
                             )
  if purchase.status == 'paid'
    user.increment!(:credits, purchase.plan_credits)
  end
end

puts "<-- Users created -->"
print "\n"

puts "<-- Creating Auctions -->"
10.times do |index|
  index += 1
  auction = Auction.new
  auction.image = File.open(Rails.root.join('spec', 'support', 'images', 'auction.jpg'))
  auction.description_url = 'http://codeland.com.br/'
  auction.happens_at = (index*10).seconds.from_now.change(usec: 0)
  auction.title = "Iphone 6 plus 32gb spacegray #{index}"
  auction.market_price = 9999.99
  print "Creating #{auction.title} \n"
  auction.save!
end
puts "<-- Auctions created -->"
print "\n"

puts "<-- Creating Auction Bids -->"
auction_ids = Auction.ids
user_ids = User.ids
rand(100).times do
  bid = AuctionBid.create(auction_id: auction_ids.sample,
                           user_id: user_ids.sample, value_in_credits: 1)
  print "- #{bid.id} "
end
print "\n"
puts "<-- Auctions Bids created -->"

puts "<-- Creating Auctions without bids -->"
2.times do |index|
  index += 1
  auction = Auction.new
  auction.image = File.open(Rails.root.join('spec', 'support', 'images', 'auction.jpg'))
  auction.description_url = 'http://codeland.com.br/'
  auction.happens_at = (index*10).seconds.from_now.change(usec: 0)
  auction.title = "No winner auction #{index}"
  auction.market_price = 9999.99
  print "Creating #{auction.title} \n"
  auction.save!
end
puts "<-- Auctions created -->"

puts "<-- Creating BestGuesses -->"

10.times do |index|
  index += 1
  best_guess = BestGuess.new
  best_guess.title = "Best_guess #{index}"
  best_guess.description_url = 'http://codeland.com.br/'
  best_guess.happens_at = index.minutes.ago.change(usec: 0)
  best_guess.ends_at = index.hours.from_now .change(usec: 0)
  best_guess.image = File.open(Rails.root.join('spec', 'support', 'images', 'best-guess.jpg'))
  best_guess.question = 'Why did the chicken cross the road?'
  best_guess.market_price = 9999.99
  best_guess.category = "Cotidiano"
  print "Creating #{best_guess.title} \n"
  best_guess.statements << Statement.new(content: "To stay on the same side (false)", answer: false)
  best_guess.statements << Statement.new(content: "You liar, she didn't! (false)", answer: false)
  best_guess.save!

end
puts "- Creating best_guesses' attempts"
statement = Statement.find(1)
other_statement = Statement.find(2)

user_id = 1
best_guess_attempt = BestGuessAttempt.create!(user: User.find(user_id), finished_at: 100.seconds.from_now, best_guess: statement.best_guess)
StatementAnswer.create!(value: false, statement: statement, best_guess_attempt: best_guess_attempt)
StatementAnswer.create!(value: true, statement: other_statement, best_guess_attempt: best_guess_attempt)

user_id = 2
best_guess_attempt = BestGuessAttempt.create!(user: User.find(user_id), finished_at: 40.seconds.from_now, best_guess: statement.best_guess)
StatementAnswer.create!(value: false, statement: statement, best_guess_attempt: best_guess_attempt)
StatementAnswer.create!(value: true, statement: other_statement, best_guess_attempt: best_guess_attempt)

user_id = 3
best_guess_attempt = BestGuessAttempt.create!(user: User.find(user_id), finished_at: 80.seconds.from_now, best_guess: statement.best_guess)
StatementAnswer.create!(value: false, statement: statement, best_guess_attempt: best_guess_attempt)
StatementAnswer.create!(value: false, statement: other_statement, best_guess_attempt: best_guess_attempt)

user_id = 4
StatementAnswer.create!(value: true, statement: statement, best_guess_attempt: BestGuessAttempt.create!(user: User.find(user_id), finished_at: (rand(20)).seconds.from_now, best_guess: statement.best_guess))

user_id = 5
StatementAnswer.create!(value: true, statement: statement, best_guess_attempt: BestGuessAttempt.create!(user: User.find(user_id), finished_at: (rand(20)).seconds.from_now, best_guess: statement.best_guess))

puts "<-- BestGuesses created -->"

puts "- Creating highlights"
Highlight.create(target: Auction.first)
puts "<-- Plans created -->"

puts "- Creating highlights"
4.times do |i|
  i += 1
  Banner.create(title: "Banner #{i}",
                image: File.open(Rails.root.join('spec', 'support', 'images', 'best-guess.jpg')),
                url: 'http://google.com')
end
puts "<-- Plans created -->"
