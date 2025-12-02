import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path/path.dart' as p;
import '../../core/constants.dart';
import '../../services/storage_service.dart';
import '../../core/utils.dart';

class CreateEventScreen extends StatefulWidget {
  final String adminUid;
  CreateEventScreen({required this.adminUid});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _loc = TextEditingController();

  DateTime? _start;
  DateTime? _end;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImages = [];
  XFile? _pickedVideo;

  // store compressed files to upload
  List<File> _imagesToUpload = [];
  File? _videoToUpload;

  final StorageService _storage = StorageService();

  // progress maps
  Map<String, double> _uploadProgress = {}; // path -> 0..1
  List<String> _uploadedImageUrls = [];
  String? _uploadedVideoUrl;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _loc.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images == null) return;
      if (images.length < 1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pick at least one image')));
      }
      setState(() => _pickedImages = images);

      // compress images in background
      _imagesToUpload = [];
      for (var x in _pickedImages) {
        final f = File(x.path);
        final compressed = await MediaUtils.compressImage(f);
        _imagesToUpload.add(compressed);
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick error: $e')));
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(maxDuration: Duration(seconds: AppConstants.maxVideoDurationSeconds));
      if (video == null) return;
      final file = File(video.path);

      // compress video
      final compressed = await MediaUtils.compressVideo(file);
      if (compressed == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video compression failed')));
        return;
      }
      if (await compressed.length() > AppConstants.maxVideoSizeBytes) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video still larger than 5MB after compression')));
        return;
      }

      setState(() {
        _pickedVideo = video;
        _videoToUpload = compressed;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video pick error: $e')));
    }
  }

  Future<void> _selectStartEnd() async {
    final now = DateTime.now();
    final s = await showDatePicker(context: context, initialDate: now, firstDate: now.subtract(Duration(days: 1)), lastDate: now.add(Duration(days: 365)));
    if (s == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    setState(() => _start = DateTime(s.year, s.month, s.day, t.hour, t.minute));
    // default end = start + 2 hours
    setState(() => _end = _start!.add(Duration(hours: 2)));
  }

  Future<void> _uploadAllAndCreate() async {
    if (_title.text.isEmpty || _start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill title, start and end')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      // images upload
      _uploadedImageUrls = [];
      for (int i = 0; i < _imagesToUpload.length; i++) {
        final file = _imagesToUpload[i];
        final remotePath = 'events/${widget.adminUid}/images';
        final task = _storage.uploadFile(file, '$remotePath/${p.basename(file.path)}');
        final id = 'img_$i';
        _uploadProgress[id] = 0.0;
        task.snapshotEvents.listen((snap) {
          final prog = (snap.bytesTransferred / (snap.totalBytes ?? snap.bytesTransferred));
          setState(() => _uploadProgress[id] = prog);
        });
        final snapshot = await task;
        final url = await snapshot.ref.getDownloadURL();
        _uploadedImageUrls.add(url);
      }

      // video upload (optional)
      if (_videoToUpload != null) {
        final remotePath = 'events/${widget.adminUid}/videos';
        final task = _storage.uploadFile(_videoToUpload!, '$remotePath/${p.basename(_videoToUpload!.path)}');
        final id = 'video';
        _uploadProgress[id] = 0.0;
        task.snapshotEvents.listen((snap) {
          final prog = (snap.bytesTransferred / (snap.totalBytes ?? snap.bytesTransferred));
          setState(() => _uploadProgress[id] = prog);
        });
        final snapshot = await task;
        final url = await snapshot.ref.getDownloadURL();
        _uploadedVideoUrl = url;
      }

      // create Firestore document
      final data = {
        'title': _title.text,
        'description': _desc.text,
        'location': _loc.text,
        'startTime': Timestamp.fromDate(_start!),
        'endTime': Timestamp.fromDate(_end!),
        'createdBy': widget.adminUid,
        'images': _uploadedImageUrls,
        'videoUrl': _uploadedVideoUrl,
        'attendeesCount': 0,
        'status': _computeStatus(_start!, _end!),
        'createdAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection(AppConstants.eventsCollection).add(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event created')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _computeStatus(DateTime s, DateTime e) {
    final now = DateTime.now();
    if (now.isBefore(s)) return 'upcoming';
    if (now.isAfter(e)) return 'completed';
    return 'ongoing';
  }

  Widget _buildImagePreview() {
    if (_imagesToUpload.isEmpty) return Text('No images');
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imagesToUpload.length,
        itemBuilder: (_, i) {
          final file = _imagesToUpload[i];
          final id = 'img_$i';
          final prog = _uploadProgress[id] ?? 0.0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Image.file(file, width: 90, height: 60, fit: BoxFit.cover),
                SizedBox(height: 4),
                if (prog > 0 && prog < 1)
                  SizedBox(width: 90, child: LinearProgressIndicator(value: prog))
                else if (prog == 1.0)
                  Icon(Icons.check, color: Colors.green)
                else
                  SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoToUpload == null) {
      return Text('No video');
    }
    final prog = _uploadProgress['video'] ?? 0.0;
    return Column(
      children: [
        Text(p.basename(_videoToUpload!.path)),
        SizedBox(height: 6),
        if (prog > 0 && prog < 1) LinearProgressIndicator(value: prog) else if (prog == 1.0) Icon(Icons.check, color: Colors.green)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: _title, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _desc, decoration: InputDecoration(labelText: 'Description'), maxLines: 3),
            TextField(controller: _loc, decoration: InputDecoration(labelText: 'Location')),
            SizedBox(height: 12),
            Row(children: [
              ElevatedButton(onPressed: _selectStartEnd, child: Text('Pick Start/End')),
              SizedBox(width: 12),
              if (_start != null) Text('Start: ${_start.toString()}'),
            ]),
            SizedBox(height: 12),
            Row(children: [
              ElevatedButton(onPressed: _pickImages, child: Text('Pick Images')),
              SizedBox(width: 8),
              ElevatedButton(onPressed: _pickVideo, child: Text('Pick Video')),
            ]),
            SizedBox(height: 12),
            _buildImagePreview(),
            SizedBox(height: 12),
            _buildVideoPreview(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _uploadAllAndCreate,
              child: _isSubmitting ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Create Event')
            )
          ],
        ),
      ),
    );
  }
}
