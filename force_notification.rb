require 'grocer'

cert_path = "certificate.pem"

pusher = Grocer.pusher(
  certificate: cert_path,        		 # required
  passphrase:  "",                       # optional
  gateway:     "gateway.sandbox.push.apple.com", # optional; See note below.
  port:        2195,                     # optional
  retries:     3                         # optional
)

notification = Grocer::Notification.new(
  device_token:      "f0dc8298c13917ba46506a0d52df4db80b7b3c915ff58d7a86eda9652b08c38a",
  alert:             "You've got a new Chain!",
  badge:             1,
  expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
  identifier:        1234,                 # optional; must be an integer
  content_available: true                  # optional; any truthy value will set 'content-available' to 1
)


pusher.push(notification)

