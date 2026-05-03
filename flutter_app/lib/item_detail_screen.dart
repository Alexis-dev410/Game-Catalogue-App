import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? 'Game Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['title'] ?? 'No Title',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildInfoChip(Icons.category, item['category'] ?? 'N/A'),
                const SizedBox(width: 10),
                _buildInfoChip(Icons.calendar_today, item['year']?.toString() ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 5),
                Text(
                  '${item['rating'] ?? '0.0'} / 10.0',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            const Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              item['description'] ?? 'No description provided.',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            // Domain specific field: Platform (from requirement 4.1)
            if (item.containsKey('platform') && item['platform'] != null) ...[
              const Text(
                'Platform',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                item['platform'],
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Added on: ${item['created_at'] ?? 'Unknown'}',
              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.blue.withOpacity(0.1),
    );
  }
}
