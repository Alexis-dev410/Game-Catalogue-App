import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'item_detail_screen.dart';
import 'add_item_screen.dart';
import 'dashboard_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  List items = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'All', 'Action', 'RPG', 'Adventure', 'Sports', 'Strategy', 'Simulation', 'Shooter'
  ];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() => isLoading = true);
    try {
      final Map<String, String> queryParams = {};
      if (_searchController.text.isNotEmpty) {
        queryParams['search'] = _searchController.text;
      }
      if (selectedCategory != 'All') {
        queryParams['category'] = selectedCategory;
      }

      // Using Uri.http is more robust as it handles parameter encoding (spaces, etc.)
      final uri = Uri.http('10.0.2.2:8000', '/items', queryParams);
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      } else {
        debugPrint("Failed to load items: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching items: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Catalog"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: "Dashboard",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by title...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: fetchItems,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onSubmitted: (_) => fetchItems(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (newValue) {
                        setState(() => selectedCategory = newValue!);
                        fetchItems();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text("No games found."))
              : RefreshIndicator(
                  onRefresh: fetchItems,
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(item["title"] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${item["category"]} • ${item["year"]}"),
                          trailing: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(item["rating"].toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailScreen(item: Map<String, dynamic>.from(item)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddItemScreen()),
        ).then((_) => fetchItems()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
