import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:8000/stats"));
      if (response.statusCode == 200) {
        setState(() {
          stats = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load stats");
      }
    } catch (e) {
      debugPrint("Error fetching stats: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stats == null || stats!['total_items'] == 0
              ? const Center(child: Text("No data available"))
              : RefreshIndicator(
                  onRefresh: fetchStats,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(),
                        const SizedBox(height: 20),
                        const Text("Items per Category",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        _buildCategoryList(),
                        const SizedBox(height: 20),
                        const Text("Top 3 Rated Games",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        _buildTopRatedList(),
                        const SizedBox(height: 20),
                        const Text("Most Recently Added",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        _buildMostRecentCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Total Games", stats!['total_items'].toString()),
            _buildStatItem("Avg Rating", stats!['average_rating'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }

  Widget _buildCategoryList() {
    final Map<String, dynamic> byCategory = stats!['by_category'];
    return Card(
      child: Column(
        children: byCategory.entries.map((e) {
          return ListTile(
            title: Text(e.key),
            trailing: Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopRatedList() {
    final List topRated = stats!['top_rated'];
    return Card(
      child: Column(
        children: topRated.map((item) {
          return ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(item['title']),
            trailing: Text(item['rating'].toString()),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMostRecentCard() {
    final mostRecent = stats!['most_recent'];
    return Card(
      child: ListTile(
        leading: const Icon(Icons.new_releases, color: Colors.orange),
        title: Text(mostRecent['title']),
        subtitle: Text("Added: ${mostRecent['created_at']}"),
      ),
    );
  }
}
