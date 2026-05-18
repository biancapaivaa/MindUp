import 'package:flutter/material.dart';
import '../models/video_model.dart';
import 'video_card.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final List<VideoModel> videos;
  final Function(VideoModel) onVideoTap;

  const CategorySection({
    super.key,
    required this.title,
    required this.videos,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.pink[700],
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return VideoCard(
                video: videos[index],
                onTap: () => onVideoTap(videos[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}