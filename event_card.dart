import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../screens/event_detail_screen.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = DateFormat.yMd().add_jm().format(event.startTime.toDate());
    final thumbnail = event.images.isNotEmpty ? event.images.first : null;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event))),
        child: Row(
          children: [
            Container(
              width: 110,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                image: thumbnail != null ? DecorationImage(image: NetworkImage(thumbnail), fit: BoxFit.cover) : null,
                color: thumbnail == null ? Colors.grey[300] : null,
              ),
              child: thumbnail == null ? Icon(Icons.event, size: 40) : null,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 6),
                    Text(start, style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(event.location, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                        Column(
                          children: [
                            Text('${event.attendeesCount}', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(event.status, style: TextStyle(fontSize: 11)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
