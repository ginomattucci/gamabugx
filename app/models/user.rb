class User < ActiveRecord::Base
  attr_accessor :recaptcha

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :auction_bids, dependent: :nullify
  has_many :auction_prizes, class_name: "Auction", foreign_key: :winner_id, dependent: :nullify
  has_many :best_guess_prizes, class_name: "BestGuess", foreign_key: :winner_id, dependent: :nullify
  has_many :best_guess_attempts, dependent: :nullify
  has_many :statement_answers, through: :best_guess_attempts
  has_many :prize_claims, dependent: :nullify
  has_many :purchases, dependent: :nullify

  validates :username, presence: true, uniqueness: true,
                       format: {
    with: /\A[a-zA-Z0-9]+\z/,
    message: 'Deve conter apenas letras e números. Sem acentos e sem espaços',
  }
  validates :terms_of_service, acceptance: { accept: 'true' }, on: :create
  validates_format_of :cpf, with: /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/,
                      message: I18n.t('errors.messages.invalid'), allow_nil: true

  validates_inclusion_of :birthday, in: Date.new(1900)..DateTime.now.years_ago(18).to_date, message: 'Você precisa ter 18 anos ou mais para se cadastrar'

  def active_for_authentication?
    super && !blocked?
  end

  def discount_partial_value
    purchases.where(status: :paid).sum(:plan_price)/2
  end

  def has_complete_profile?
    required_attrs = %i(
      address
      city
      country
      cpf
      fullname
      neighborhood
      phone
      uf
      zip_code
    )
    some_attribute_is_blank = required_attrs.detect{ |attr| send(attr).blank? }
    !some_attribute_is_blank
  end
end
