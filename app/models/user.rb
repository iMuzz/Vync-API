class User < ActiveRecord::Base

  has_many :sent_messages, class_name: "VideoMessage", foreign_key: :sender_id
  has_many :received_messages, class_name: "VideoMessage", foreign_key: :recipient_id
  validates :email, uniqueness: true

  def self.all_since(since = 0)
    past = User.all.limit(since)
    User.where.not(id: past.pluck(:id))
  end

  def all_messages(since = 0)
    past = VideoMessage.all.limit(since)
    past_chains = past.chains(messages.where(id < since))
    VideoMessage.chains(messages).where.not(id: past_chains.pluck(:id))
  end

  def messages
    VideoMessage.where("sender_id = ? or recipient_id = ?", id, id)
  end

end
