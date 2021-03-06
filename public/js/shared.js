$(document).ready(function() {
// get player
var player = document.getElementById("player")
var videoSource = new Array();
var i = 0
$.get( '/shared', player.dataset, function(data){
	videoSource = data
	videoCount = videoSource.length
	player.setAttribute("src",videoSource[0]); 
		player.play()
	}, 'json');

	// Add an event listener with 'ended' as first parameter which detects the completion of the event.
	player.addEventListener('ended',videoCycle,false);
	player.addEventListener('click',function(){
		if (player.paused){
			player.play();
		}else{
			player.pause()
		}
	},false);

	// Create a function to load and play the videos.
	function videoPlay(videoNum) {
		player.setAttribute("src",videoSource[videoNum]);
		player.load();
		player.play();
	}

	function videoCycle() {
		i++;
		if(i == (videoCount)){
			i = 0;
			videoPlay(i);
		}
		else{
			videoPlay(i);
		}
	}

})