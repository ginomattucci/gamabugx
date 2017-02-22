class ChangeIntegerLimitCountdownTimer < ActiveRecord::Migration
  def change
    change_column :auctions, :countdown_timer, :integer, limit: 8
    change_column :best_guesses, :duration_time, :integer, limit: 8
  end
end
