helpers do

  def notify(device_token, notification_text)
    notification = Grocer::Notification.new(
      device_token:      device_token,
      alert:             notification_text,
      badge:             1,
      expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
      identifier:        1234,                 # optional; must be an integer
      content_available: true                  # optional; any truthy value will set 'content-available' to 1
    )

    PUSHCLIENT.push(notification)
  end

end
