get '/' do
  erb :index
end

get '/users' do
  content_type :json
  User.all.to_json
end

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
  "success"
end

get '/users/:facebook_object_id/videos' do
  content_type :json
  User.find_by(facebook_object_id: params[:facebook_object_id]).all_messages(params[:since].to_i).to_json
end

post '/users/:facebook_object_id/videos' do
  tempfile = request.params["file"][:tempfile]
  video_params = params[:json]
  # Upload to s3 if it doesn't already exist
  return "Already There" if VideoMessage.find_by(video_id: video_params[:video_id])
  $s3.buckets.first.objects.create(video_params[:video_id], tempfile)
  # Instantiate a new videomessage object
  new_vid = VideoMessage.create(
    sender_id: video_params[:sender_id],
    recipient_id: video_params[:recipient_id],
    video_id: video_params[:video_id]
  )
  # If there was a replyId sent with this request use that,
  # otherwise assume it's the first video in a chain and set the reply_to_id
  # to its own id
  if video_params[:reply_to_id] == "0"
    new_vid.reply_to_id = new_vid.id
    new_vid.title = video_params[:title]
  else
    new_vid.reply_to_id = video_params[:reply_to_id]
  end
  new_vid.save!
  devices = new_vid.user_ids_to_be_notified.map {|id| User.find(id).device_token }
  notify_all(devices, "Your video has been forwarded!")
# Notify the recipient of their new message
  recipient = User.find(video_params[:recipient_id])
  notify(recipient.device_token, "You have a new video, watch it now!")
  "#{new_vid.id},#{new_vid.created_at},#{new_vid.reply_to_id}"
end

# Currently downloading straight from S3, but we could re-implement this if we had safety concerns.
# get '/download' do
#   send_file $s3.buckets.first.objects[params[:download]].read, :type => :mov
# end
