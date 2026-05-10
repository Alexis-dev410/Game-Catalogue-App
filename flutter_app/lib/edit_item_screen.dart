import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditItemScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditItemScreen({super.key, required this.item});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _yearController;
  late TextEditingController _ratingController;
  late TextEditingController _descriptionController;
  late TextEditingController _platformController;

  late String _selectedCategory;
  final List<String> _categories = [
    'Action', 'RPG', 'Adventure', 'Sports', 'Strategy', 'Simulation', 'Shooter', 'Sandbox', 'Racing', 'Fighting'
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item['title']?.toString() ?? "");
    _yearController = TextEditingController(text: widget.item['year']?.toString() ?? "");
    _ratingController = TextEditingController(text: widget.item['rating']?.toString() ?? "");
    _descriptionController = TextEditingController(text: widget.item['description']?.toString() ?? "");
    _platformController = TextEditingController(text: widget.item['platform']?.toString() ?? "");
    
    String cat = widget.item['category']?.toString() ?? 'Action';
    _selectedCategory = _categories.contains(cat) ? cat : _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _ratingController.dispose();
    _descriptionController.dispose();
    _platformController.dispose();
    super.dispose();
  }

  Future<void> _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Strict type conversion to avoid 422 Unprocessable Entity errors
    final Map<String, dynamic> updatedData = {
      "title": _titleController.text.trim(),
      "category": _selectedCategory,
      "year": int.tryParse(_yearController.text) ?? int.tryParse(widget.item['year'].toString()) ?? 2024,
      "rating": double.tryParse(_ratingController.text) ?? double.tryParse(widget.item['rating'].toString()) ?? 0.0,
      "description": _descriptionController.text.trim(),
      "platform": _platformController.text.trim(),
    };

    try {
      final uri = Uri.http('10.0.2.2:8000', '/items/${widget.item['id']}');
      
      final response = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          final updatedItem = Map<String, dynamic>.from(json.decode(response.body));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Game updated successfully!")),
          );
          Navigator.pop(context, updatedItem); 
        }
      } else {
        // Log the actual server error to help debug
        debugPrint("Server error: ${response.body}");
        throw Exception("Server Error ${response.statusCode}: Please check your inputs.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Game")),
      body: _isSubmitting 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Title*", border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? "Enter a title" : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(labelText: "Year*", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? "Enter year" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ratingController,
                    decoration: const InputDecoration(labelText: "Rating (0-10)*", border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter rating";
                      double? r = double.tryParse(value);
                      if (r == null || r < 0 || r > 10) return "Enter a number between 0 and 10";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _platformController,
                    decoration: const InputDecoration(labelText: "Platform", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      onPressed: _updateData,
                      child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
