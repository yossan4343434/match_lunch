class User < ApplicationRecord
  has_many :standbies, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def standbies_on_or_after_today
    Standby.where("user_id = :user_id AND date >= :today", user_id: id, today: Time.zone.today)
  end

  def standby_today
    Standby.where("user_id = :user_id AND date = :today", user_id: id, today: Time.zone.today)
  end

  def home_today(user)
    todays_match = Match.where(date: Time.zone.today).find_by("home_id = #{user.id} OR away_id = #{user.id} OR referee_id = #{user.id}")
    User.find(todays_match.home_id) if todays_match && todays_match.home_id
  end

  def away_today(user)
    todays_match = Match.where(date: Time.zone.today).find_by("home_id = #{user.id} OR away_id = #{user.id} OR referee_id = #{user.id}")
    User.find(todays_match.away_id) if todays_match && todays_match.away_id
  end

  def referee_today(user)
    todays_match = Match.where(date: Time.zone.today).find_by("home_id = #{user.id} OR away_id = #{user.id} OR referee_id = #{user.id}")
    User.find(todays_match.referee_id) if todays_match && todays_match.referee_id
  end

  private
    
    def downcase_email
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
