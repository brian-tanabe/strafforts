class Athlete < ApplicationRecord
  validates :access_token, presence: true
  validates :is_active, :is_public, inclusion: { in: [true, false] }

  has_one :athlete_info
  has_one :stripe_customer

  has_many :activities
  has_many :best_efforts
  has_many :gears
  has_many :heart_rate_zones
  has_many :races
  has_many :subscriptions

  before_create :generate_confirmation_token

  def self.find_by_access_token(access_token)
    results = where(access_token: access_token)
    results.empty? ? nil : results.take
  end

  def self.find_all_by_is_active(is_active = true)
    results = where('is_active = ?', is_active).order('updated_at')
    results.empty? ? [] : results
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32).to_s if confirmation_token.blank?
  end
end
