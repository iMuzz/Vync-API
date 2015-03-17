class VideoMessage < ActiveRecord::Base
  belongs_to :sender, class_name: "User", foreign_key: :user_id
  belongs_to :recipient, class_name: "User", foreign_key: :user_id
  validates :video_id, uniqueness: true

  def is_first_message?
    reply_to_id == id
  end

  def is_finished?
    show_chain.size == 6
  end

  def is_last_link?
    self == show_chain.last
  end

  def chain
    VideoMessage.where(reply_to_id: reply_to_id)
  end

  def self.chains(messages)
    where(reply_to_id: messages.pluck(:reply_to_id))
  end

  def user_ids_to_be_notified
    ids = chain.pluck(:sender_id)
    ids.pop
    ids
  end

  def source
    "https://s3-us-west-2.amazonaws.com/telephono/#{self.video_id}.mov"
  end
end
