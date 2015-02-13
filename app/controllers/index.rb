get '/' do
  erb :index
end

get '/users' do
  content_type :json
  User.all.to_json
end

  # user = User.create(devicetoken: params[:devicetoken], device_id: params[:deviceID], username: params[:username])
post '/users' do
  # ignore id
  user_params = params[:json].reject {|k| k == "id" || k == "is_me" }
  if exists = User.find_by(email: user_params[:email])
    exists.id.to_s
  else
    user = User.create(user_params)
    user.id.to_s
  end
end

put '/users/:facebook_object_id' do
  user = User.find_by(facebook_object_id: params[:facebook_object_id])
  if user.device_token != params[:device_token]
    user.device_token = params[:device_token]
    user.save!
  end
  notify(user.device_token, "Welcome to VYNC!")
end

get '/users/:facebook_object_id/videos' do
  content_type :json
  User.find_by(facebook_object_id: params[:facebook_object_id]).all_messages(params[:since].to_i).to_json
end

post '/users/:facebook_object_id/videos' do
  tempfile = request.params["file"][:tempfile]
  # Upload to s3!
  puts "before upload"
  $s3.buckets.first.objects.create(params[:json][:video_id], tempfile)
  puts "after upload"

  # Instantiate a new videomessage object
  new_vid = VideoMessage.create(
    sender_id: params[:json][:sender_id],
    recipient_id: params[:json][:recipient_id],
    video_id: params[:json][:video_id]
  )
  # If there was a replyId sent with this request use that,
  # otherwise assume it's the first video in a chain and set the reply_to_id
  # to its own id
  if params[:json][:reply_to_id] == "0"
    new_vid.reply_to_id = new_vid.id
    new_vid.title = params[:json][:title]
  else
    new_vid.reply_to_id = params[:json][:reply_to_id]
  end
  new_vid.save!


  # notify all users on chain. Needs to be redone
    notify_all(new_vid.to_be_notified(params[:json][:sender_id],params[:json][:recipient_id]), "Your video has been forwarded!")
  # Notify the recipient of their new message
    notify(recipient.devicetoken, "You have a new video, watch it now!")

  puts "ready to send back"
  "#{new_vid.id},#{new_vid.created_at},#{new_vid.reply_to_id}"
end

# Currently downloading straight from S3, but we could re-implement this if we had safety concerns.
# get '/download' do
#   send_file $s3.buckets.first.objects[params[:download]].read, :type => :mov
# end
