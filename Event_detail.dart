import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../widgets/image_carousel.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import '../../repositories/event_repository.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;
  EventDetailScreen({required this.event});
  @override State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Timer? _timer;
  Duration _remaining = Duration();
  VideoPlayerController? _videoController;
  final _repo = EventRepository();
  bool _isInterestedProcessing = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    if (widget.event.videoUrl != null) {
      _videoController = VideoPlayerController.network(widget.event.videoUrl!)
        ..initialize().then((_) => setState(() {}));
    }
  }

  void _startTimer() {
    final now = DateTime.now();
    final start = widget.event.startTime.toDate();
    final end = widget.event.endTime.toDate();
    final target = now.isBefore(end) ? (now.isBefore(start) ? start : end) : end;
    setState(() => _remaining = target.difference(now));
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _remaining = _remaining - Duration(seconds: 1);
        if (_remaining.isNegative) _timer?.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return 'Completed';
    final days = d.inDays;
    final hrs = d.inHours % 24;
    final mins = d.inMinutes % 60;
    final secs = d.inSeconds % 60;
    return '${days}d ${hrs}h ${mins}m ${secs}s';
  }

  Future<void> _markInterested() async {
    if (_isInterestedProcessing) return;
    setState(() => _isInterestedProcessing = true);
    try {
      // increment attendeesCount atomically
      await _repo.incrementAttendees(widget.event.id, 1);
      // Optionally, add to user's interested list (requires user auth)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked interested')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isInterestedProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = DateFormat.yMd().add_jm().format(widget.event.startTime.toDate());
    final end = DateFormat.yMd().add_jm().format(widget.event.endTime.toDate());
    return Scaffold(
      appBar: AppBar(title: Text(widget.event.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageCarousel(images: widget.event.images),
            if (_videoController != null && _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_videoController!),
                    VideoProgressIndicator(_videoController!, allowScrubbing: true),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: IconButton(
                        icon: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ListTile(title: Text('Location'), subtitle: Text(widget.event.location)),
            ListTile(title: Text('Starts'), subtitle: Text(start)),
            ListTile(title: Text('Ends'), subtitle: Text(end)),
            SizedBox(height: 8),
            Text('Time left: ${_formatDuration(_remaining)}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isInterestedProcessing ? null : _markInterested,
              child: _isInterestedProcessing ? CircularProgressIndicator(color: Colors.white) : Text('Mark Interested (${widget.event.attendeesCount})'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
