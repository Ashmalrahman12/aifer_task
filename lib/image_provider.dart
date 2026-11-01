import 'dart:convert';
import 'package:aifer_task/image_model.dart'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageListProvider with ChangeNotifier {
  List<ImageModel> _images = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = ''; 

 
  List<ImageModel> get images {
    if (_searchQuery.isEmpty) {
      return _images;
    }
    return _images.where((img) => 
      img.author.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  
  void searchImages(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchImages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://picsum.photos/v2/list'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _images = data.map((json) => ImageModel.fromJson(json)).toList();
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load images: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error occurred.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}