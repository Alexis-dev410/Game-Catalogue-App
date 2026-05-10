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
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final uri = Uri.http('10.0.2.2:8000', '/stats');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            stats = json.decode(response.body);
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load stats: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching stats: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not connect to the server.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stats == null || stats!['total_items'] == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("No data available yet."),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: fetchStats, child: const Text("Retry")),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchStats,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Games per Category"),
                        _buildCategoryList(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Top 3 Rated Games"),
                        _buildTopRatedList(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Most Recently Added"),
                        _buildMostRecentCard(),
                        const SizedBox(height: 100), // Padding for bottom nav
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Colors.indigo.shade700,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Total Games", stats!['total_items'].toString()),
            Container(width: 1, height: 40, color: Colors.white24),
            _buildStatItem("Avg Rating", stats!['average_rating'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildCategoryList() {
    final Map<String, dynamic> byCategory = stats!['by_category'] ?? {};
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: byCategory.entries.map((e) {
          return ListTile(
            dense: true,
            title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: Chip(
              label: Text(e.value.toString(), style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.indigo.shade50,
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopRatedList() {
    final List topRated = stats!['top_rated'] ?? [];
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: topRated.map((item) {
          return ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(item['title'] ?? "Unknown", maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(item['rating']?.toString() ?? "0.0", style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMostRecentCard() {
    final mostRecent = stats!['most_recent'];
    if (mostRecent == null) return const Card(child: ListTile(title: Text("No items yet")));

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.new_releases, color: Colors.white),
        ),
        title: Text(mostRecent['title'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Added: ${mostRecent['created_at']?.toString().split(' ')[0] ?? 'Unknown'}"),
      ),
    );
  }
}
