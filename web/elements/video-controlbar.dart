library videoControlBar;
import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('video-controlbar')

class VideoControlBar extends PolymerElement {

  //published attributes
  @published bool isPlaying;
  @published double setProgress;
  @published int progressIndicator;
  @published int duration;
  @published String quality;
  @published double speed;
  @published int volume;
  @published bool isFullscreen;
  int returnVolume = 50;
  
  @observable
  VideoControlBar.created() : super.created() { }
  
  @override
  void attached() {
    super.attached();
  }
  
  //PlayPause
  void togglePlayPause(Event e, var details, Node target){
    isPlaying = !isPlaying;
  }
  
  void isPlayingChanged(){
    if(isPlaying){
      $['playPauseButton'].attributes['icon'] = "av:pause";
    }
    else{
      $['playPauseButton'].attributes['icon'] = "av:play-arrow";
    }
  }
  
  //Speed
  void toggleSpeed(Event e, var details, Node target){
    if(speed == 1.0){
      speed = 1.3;
    }
    else if(speed == 1.3){
      speed = 1.7;
    }
    else if(speed == 1.7){
      speed = 0.7;
    }
    else {
      speed = 1.0;
    }
  }
  
  //Volume
  void toggleMute(Event e, var details, Node target){
    if(volume>0){
      returnVolume = volume;
      volume = 0;
    }
    else{
      volume = returnVolume;
    } 
  }
  
  void volumeChanged(){
    if(volume==0){
      $['volumeButton'].attributes['icon'] = "av:volume-off";
    }
    if(volume>0 && volume<=30){
      $['volumeButton'].attributes['icon'] = "av:volume-mute";
    }
    if(volume>30 && volume<=70){
      $['volumeButton'].attributes['icon'] = "av:volume-down";
    }
    if(volume>70 && volume<=100){
      $['volumeButton'].attributes['icon'] = "av:volume-up";
    }
  }

  //Quality
  void toggleQuality(){
    if(quality == "sd"){
      quality = "hd";
      $['qualityButton'].text = "HD";
    }
    else {
      quality = "sd";
      $['qualityButton'].text = "SD";
    }
  }
  
  String secondsToMinutes(int number){
    int minutes = number ~/ 60;
    int seconds = number % 60;
    String placeholder;
    if(seconds<10){placeholder="0";}else{placeholder="";}
    return '$minutes:$placeholder$seconds';
  }
  
  String doubleToSpeedRepresentation(double speed){
    return speed.toStringAsFixed(1)+'x';
  }
}