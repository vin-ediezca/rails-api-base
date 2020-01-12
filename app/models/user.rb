class User < ApplicationRecord
  has_one :access_token, dependent: :destroy
  has_many :articles, dependent: :destroy

  validates :login, presence: true, uniqueness: true
  validates :provider, presence: true
end
