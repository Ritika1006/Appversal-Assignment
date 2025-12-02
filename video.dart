import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({required this.videoUrl});

  @override State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return Container(height: 220, child: Center(child: CircularProgressIndicator()));
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller!),
          VideoProgressIndicator(_controller!, allowScrubbing: true),
          Positioned(
            left: 8,
            bottom: 8,
            child: IconButton(
              icon: Icon(_controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle_fill, color: Colors.white, size: 30),
              onPressed: () => setState(() => _controller!.value.isPlaying ? _controller!.pause() : _controller!.play()),
            ),
          )
        ],
      ),
    );
  }
}
