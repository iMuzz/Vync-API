helpers do

  def notify(devicetoken, notification_text)
    notification = Grocer::Notification.new(
      device_token:      devicetoken,
      alert:             notification_text,
      badge:             1,
      expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
      identifier:        1234,                 # optional; must be an integer
      content_available: true                  # optional; any truthy value will set 'content-available' to 1
      )
    PUSHCLIENT.push(notification)
  end

  def notify_all(tokens, notification_text)
    tokens.each do |user|
      notfiy(token, notification_text)
    end
  end

end
