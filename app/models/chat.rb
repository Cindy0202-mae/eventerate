class Chat < ApplicationRecord
  belongs_to :event
  has_many :messages
  has_many :chat_users, dependent: :destroy
  has_many :users, through: :chat_users
end
