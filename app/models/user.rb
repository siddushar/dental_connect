class User < ApplicationRecord
  has_one :candidate_profile, dependent: :destroy

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
