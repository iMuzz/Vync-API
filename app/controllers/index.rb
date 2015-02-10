get '/' do
  erb :index
end

get '/users' do
  content_type :json
  User.all.to_json
end

  # user = User.create(devicetoken: params[:devicetoken], device_id: params[:deviceID], username: params[:username])
  # notify(params[:deviceToken], "Welcome to Chainer!")
post "/users" do
  user_params = params[:json].reject {|k| k == "id" || k == "is_me" }
  puts "post user route. params=#{user_params}"

  # ignore id

  user = User.new(user_params)
  if user.save
    user.id.to_s
  else
    "User with that name already exists"
  end
end

get '/users/:facebook_object_id/videos' do
  content_type :json
  User.find_by(facebook_object_id: params[:facebook_object_id]).all_messages(params[:since].to_i).to_json
end

post '/users/:facebook_object_id/videos' do
  tempfile = request.params["file"][:tempfile]
  # Upload to s3!
  $s3.buckets.first.objects.create(params[:json][:video_id], tempfile)

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
    new_vid.reply_to_id = params[:reply_to_id]
  end
  new_vid.save!

# notify all users on chain. Needs to be redone
  # user_ids = new_vid.chain.map {|video| [video.sender_id, video.recipient_id]}.flatten.uniq
  # following_user_ids = user_ids.reject {|id| id == sender.id || id == recipient.id}
  # following_user_ids.each do |id|
  #   notify(User.find(id).devicetoken, "Your video has been forwarded!")
  # end
  # # Notify the recipient of their new message
  # notify(recipient.devicetoken, "You have a new video, watch it now!")
  "#{new_vid.id},#{new_vid.created_at},#{new_vid.reply_to_id}"
end

# Currently downloading straight from S3, but we could re-implement this if we had safety concerns.
# get '/download' do
#   send_file $s3.buckets.first.objects[params[:download]].read, :type => :mov
# end
