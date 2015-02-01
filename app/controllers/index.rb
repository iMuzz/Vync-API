get '/' do
  puts "get!"
  erb :index
end

get '/users' do
  content_type :json
  User.all.to_json
end

get '/videomessages/:device_id/all' do
  content_type :json
  User.find_by(device_id: params[:device_id]).all_messages(params[:since].to_i).to_json
end

post '/upload' do
  tempfile = request.params["file"][:tempfile]
  # A random hex to use as a filename, shasum was not working...
  video_id = SecureRandom.hex + ".mov"
  # Instantiate a new videomessage object
  sender = User.find_by(device_id: params[:senderDevice])
  recipient = User.find(params[:recipient])
  new_vid = VideoMessage.new(sender_id: sender.id, recipient_id: params[:recipient], video_id: video_id)
  # If there was a replyId sent with this request use that,
  # otherwise assume it's the first video in a chain and set the reply_to_id
  # to its own id
  new_vid.save!
  if params[:replyToID] == "0"
    new_vid.reply_to_id = new_vid.id
    new_vid.title = params["title"]
  else
    new_vid.reply_to_id = params[:replyToID]
  end
  new_vid.save!

  # Upload to s3!
  $s3.buckets.first.objects.create(video_id, tempfile)
# notify all users on chain
  user_ids = new_vid.chain.map {|video| [video.sender_id, video.recipient_id]}.flatten.uniq
  following_user_ids = user_ids.reject {|id| id == sender.id || id == recipient.id}
  following_user_ids.each do |id|
    notify(User.find(id).devicetoken, "Your video has been forwarded!")
  end
  # Notify the recipient of their new message
  notify(recipient.devicetoken, "You have a new video, watch it now!")
  "Hey There Cowboy"
end

get '/download' do
  send_file $s3.buckets.first.objects[params[:download]].read, :type => :mov
end

post "/newuser" do
  user = User.create(devicetoken: params[:devicetoken], device_id: params[:deviceID], username: params[:username])
  notify(params[:deviceToken], "Welcome to Chainer!")

  user.id.to_s
end
