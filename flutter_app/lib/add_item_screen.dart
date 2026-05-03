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
  final _platformController = TextEditingController(); // Domain specific

  String _selectedCategory = 'Action';
  final List<String> _categories = ['Action', 'RPG', 'Adventure', 'Sports', 'Strategy', 'Simulation', 'Shooter'];

  bool _isSubmitting = false;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final Map<String, dynamic> itemData = {
      "title": _titleController.text,
      "category": _selectedCategory,
      "year": int.parse(_yearController.text),
      "rating": double.parse(_ratingController.text),
      "description": _descriptionController.text,
      "platform": _platformController.text, // Optional domain-specific field
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/items"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(itemData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Game added successfully!")),
        );
        Navigator.pop(context); // Go back to list
      } else {
        throw Exception("Failed to add item: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
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
                    decoration: const InputDecoration(labelText: "Title*"),
                    validator: (value) => value!.isEmpty ? "Enter a title" : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                  TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(labelText: "Year*"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Enter year" : null,
                  ),
                  TextFormField(
                    controller: _ratingController,
                    decoration: const InputDecoration(labelText: "Rating (0-10)*"),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) return "Enter rating";
                      double? r = double.tryParse(value);
                      if (r == null || r < 0 || r > 10) return "Enter a number between 0 and 10";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _platformController,
                    decoration: const InputDecoration(labelText: "Platform (e.g. PC, PS5)"),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitData,
                    child: const Text("Add Game"),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
