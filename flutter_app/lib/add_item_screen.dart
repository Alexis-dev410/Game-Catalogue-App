import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _ratingController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _platformController = TextEditingController();

  String _selectedCategory = 'Action';
  
  // Unified category list to match Browse and Edit screens
  final List<String> _categories = [
    'Action', 'RPG', 'Adventure', 'Sports', 'Strategy', 'Simulation', 'Shooter', 'Sandbox', 'Racing', 'Fighting'
  ];

  bool _isSubmitting = false;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final Map<String, dynamic> itemData = {
      "title": _titleController.text.trim(),
      "category": _selectedCategory,
      "year": int.tryParse(_yearController.text) ?? 2024,
      "rating": double.tryParse(_ratingController.text) ?? 0.0,
      "description": _descriptionController.text.trim(),
      "platform": _platformController.text.trim(),
    };

    try {
      final uri = Uri.http('10.0.2.2:8000', '/items');
      
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(itemData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Game added successfully!")),
          );
          Navigator.pop(context, true); 
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Game")),
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
                      onPressed: _submitData,
                      child: const Text("Add Game", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
