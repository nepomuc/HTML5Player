library videoPlayer;
import 'package:polymer/polymer.dart';
import 'package:core_elements/core_icon.dart';
import 'video-stream.dart';
import 'video-controlbar.dart';
import 'dart:html';

@CustomTag('video-player')
class VideoPlayer extends PolymerElement {
  
  //published attributes
  @published bool autoplay = false;
  @published int duration = 1;
  @published double speed = 1.0;
  @published String quality = "sd";
  @published int volume = 80;
  @published bool showSubtitles = false;
  @published int progress = 0;
  
  @observable bool isPlaying = false;
  @observable bool isFullscreen = false;

  
  double startX;
  double startWidth;
  var mouseMoveListener;
  var mouseUpListener;
  
  //referenced elements
  ElementList<VideoStream> videoStreamList;
  VideoControlBar videoControlBar;

  @observable
  VideoPlayer.created() : super.created() { }
  
  @override
  void attached() {
    videoStreamList = this.querySelectorAll("video-stream");
    videoControlBar = $["videoControlBar"];

    this.querySelector("video-stream:last-child").setAttribute("flex", "");
    
    document.onFullscreenChange.listen(handleFullscreenChanged);
    isPlaying = autoplay;
    
    for(int i=0; i<videoStreamList.length-1; i++){
      CoreIcon resizer = new Element.tag('core-icon');
      resizer.id = "resizer";
      resizer.icon = "polymer";
      resizer.onMouseDown.listen((MouseEvent e) => initDrag(e, i));
      this.insertBefore(resizer, videoStreamList[i].nextNode);
    }
    
    videoStreamList.forEach((stream) => stream.resize(videoStreamList.length));
    
    
    /* manage bindings */

    //PlayPause
    videoStreamList.forEach((stream) => 
      stream.bind('isPlaying', new PathObserver(videoControlBar, 'isPlaying'))
    );
    videoControlBar.bind('isPlaying', new PathObserver(videoStreamList[0], 'isPlaying'));

    //Progress
    videoStreamList.forEach((stream) => 
        videoControlBar.bind('progress', new PathObserver(stream, 'progress'))
    );
    videoControlBar.bind('buffered', new PathObserver(videoStreamList[0], 'buffered'));
    videoControlBar.progress = progress;
    
    videoControlBar.duration = duration;
    videoControlBar.bind('duration', new PathObserver(videoStreamList[0], 'duration'));
    
    //Quality
    videoStreamList.forEach((stream) => 
      stream.bind('isHD', new PathObserver(videoControlBar, 'isHD'))
    );
    videoControlBar.isHD = (quality=="hd");
    
    //Speed
    videoStreamList.forEach((stream) => 
      stream.bind('speed', new PathObserver(videoControlBar, 'speed'))
    );
    videoControlBar.speed = speed;
    
    //Volume
    videoStreamList.forEach((stream) => 
      stream.bind('volume', new PathObserver(videoControlBar, 'volume'))
    );
    videoControlBar.volume = volume; 
  }
  
  /* dragging stuff */
  
  void initDrag([MouseEvent e, int scopeVideo]){
    startX = e.client.x;
    startWidth = double.parse( videoStreamList[scopeVideo].getComputedStyle().width.replaceAll('px', '') );
    mouseUpListener = $['videoArea'].onMouseUp.listen(stopDrag);
    mouseMoveListener = $['videoArea'].onMouseMove.listen(doDrag);
  }
  
  void doDrag([MouseEvent e]){
    
    double controlbarHeight = 48.0;
    
    if (double.parse(videoStreamList[0].style.width.replaceAll('px', '')) < (startWidth + e.client.x - startX)){
      if ((double.parse(videoStreamList[0].style.height.replaceAll('px', '')) <= (double.parse(videoStreamList[1].style.height.replaceAll('px', '')))) && 
              (document.documentElement.clientHeight <= double.parse( this.getComputedStyle().height.replaceAll('px', ''))+controlbarHeight ) || 
              (document.documentElement.clientHeight > double.parse( this.getComputedStyle().height.replaceAll('px', ''))+controlbarHeight )) {
            videoStreamList[0].style.width = (startWidth + e.client.x - startX).toString() + "px";
      }
      videoStreamList.first.resize(videoStreamList.length);
      videoStreamList.last.resize(videoStreamList.length);
    }
    else if (double.parse(videoStreamList[0].style.width.replaceAll('px', '')) > (startWidth + e.client.x - startX)) {
      if ((double.parse(videoStreamList[0].style.height.replaceAll('px', '')) >= (double.parse(videoStreamList[1].style.height.replaceAll('px', '')))) && 
              (document.documentElement.clientHeight <= double.parse( this.getComputedStyle().height.replaceAll('px', ''))+controlbarHeight ) || 
              (document.documentElement.clientHeight > double.parse( this.getComputedStyle().height.replaceAll('px', ''))+controlbarHeight )) {
            videoStreamList[0].style.width = (startWidth + e.client.x - startX).toString() + "px";
      }
      videoStreamList.last.resize(videoStreamList.length);
      videoStreamList.first.resize(videoStreamList.length);
    }
  }
  
  void stopDrag([MouseEvent e]){
    mouseMoveListener.cancel();
    mouseUpListener.cancel();
  }
  
  //PlayPause
  void isPlayingChanged([Event e]){
    if(isPlaying){
      play();
    } else {
      pause();
    }
  }
  
  void play([Event e]){
    isPlaying = true;
  }
  
  void pause([Event e]){
    isPlaying = false;
  }
  
  void replay(){
    videoStreamList.forEach(
        (stream) => stream.isPlaying = true
    );
    isPlaying = true;
  }
  
  // Fullscreen
  void toggleFullscreen(Event e, var details, Node target){
      isFullscreen = !isFullscreen;
  }
  
  void isFullscreenChanged(){
    if(isFullscreen){
      this.requestFullscreen();
    }else{
      document.exitFullscreen();      
    }
  }
  
  void handleFullscreenChanged(Event e){
    //updates the video size
    if (document.fullscreenElement==null)
      isFullscreen=false;
    else isFullscreen=true;
    videoStreamList[0].style.width = (double.parse( this.getComputedStyle().width.replaceAll('px', '')) / 2).toString() + "px";
    videoStreamList.forEach((stream) => stream.resize(videoStreamList.length));
  }
  
  //Subtitles
  void showSubtitlesChanged(){
    if(showSubtitles){
      videoStreamList.forEach(
        (stream) => stream.showSubtitles()
      );
    }
    else {
      videoStreamList.forEach(
        (stream) => stream.hideSubtitles()
      );
    }
  }
  
}

