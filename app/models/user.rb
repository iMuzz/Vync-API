class User < ActiveRecord::Base

  has_many :sent_messages, class_name: "VideoMessage", foreign_key: :sender_id
  has_many :received_messages, class_name: "VideoMessage", foreign_key: :recipient_id
  validates :email, uniqueness: true

  def self.all_since(since = 0)
    past = User.where("id > ?", since)
  end

  def all_messages(since = 0)
    # This more complicated set of queries is required because you
    # might have a message with id 10 (since = 10), but then you
    # are added to a chain that has messages at ids lower than 10.

    # Get all videos that are already synced to the phone
    past = VideoMessage.where("id <= ?", since)
    # Get all the chains for those videos
    past_chains = past.chains(messages.where("id <= ?", since))
    # Return all my chains that aren't part of past chains
    VideoMessage.chains(messages).where.not(id: past_chains.pluck(:id))
  end

  def messages
    VideoMessage.where("sender_id = ? or recipient_id = ?", id, id)
  end

end
