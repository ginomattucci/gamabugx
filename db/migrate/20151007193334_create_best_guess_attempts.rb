class CreateBestGuessAttempts < ActiveRecord::Migration
  def change
    create_table :best_guess_attempts do |t|
      t.references :user, index: true
      t.references :best_guess, index: true
      t.datetime :finished_at

      t.timestamps null: false
    end
  end
end
