import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/grocery_item_tile.dart';
import '../model/cart_model.dart';
import 'cart_page.dart';
import 'intro_screen.dart';
import 'products_list_page.dart';

class AdminHomePage extends StatefulWidget {
  final String username;

  const AdminHomePage({Key? key, required this.username}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _HomePageState();
}

class Product {
  String name;
  double price;
  String imageUrl;

  Product({required this.name, required this.price, required this.imageUrl});
}

class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Associate the GlobalKey with the Form
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Product Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a product name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: priceController,
            decoration: InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a price';
              }
              return null;
            },
          ),
          TextFormField(
            controller: imageUrlController,
            decoration: InputDecoration(labelText: 'Image URL'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an image URL';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Validate form and add product to Firestore
              if (_formKey.currentState!.validate()) {
                _addProductToFirestore();
              }
            },
            child: Text('Add Product'),
          ),
        ],
      ),
    );
  }

  void _addProductToFirestore() {
    // Get values from controllers and add product to Firestore
    String name = nameController.text;
    double price = double.parse(priceController.text);
    String imageUrl = imageUrlController.text;

    // Create a Product object
    Product newProduct = Product(name: name, price: price, imageUrl: imageUrl);

    // Create a map from the Product object
    Map<String, dynamic> productMap = {
      'name': newProduct.name,
      'price': newProduct.price,
      'imageUrl': newProduct.imageUrl,
    };

    // Add the product to Firestore
    FirebaseFirestore.instance.collection('products').add(productMap);

    // Show a success message
    _showSuccessMessage();

    // Clear the form
    _clearForm();
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product added successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearForm() {
    nameController.clear();
    priceController.clear();
    imageUrlController.clear();
  }
}

class _HomePageState extends State<AdminHomePage> {
  String time = '';
  String date = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchDateTime();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductsListPage(), // Create OrderHistoryPage
          ),
        );
      }
    });
  }

  void _onItemTappedLogOut(int index) {
    if (index == 2) {
      _showLogoutConfirmationDialog();
    } else {}
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform logout action
                _logout();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => IntroScreen()));
  }

  Future<void> _fetchDateTime() async {
    try {
      final response =
      await http.get(Uri.parse('https://worldtimeapi.org/api/ip'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        time = DateFormat('jm').format(DateTime.parse(data['datetime']));
        date = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['datetime']));
        setState(() {});
      } else {
        print('Failed to load time and date: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching time and date: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: GestureDetector(
            onTap: () {
              String username = widget.username;
            },
            child: Icon(
              Icons.person,
              color: Colors.grey[700],
            ),
          ),
        ),
        title: Text(
          'Welcome, ${widget.username}!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        centerTitle: false,
        actions: [
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),

          // time and date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // good morning bro
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
          ),

          const SizedBox(height: 4),

          // Let's order fresh items for you
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Add New Product",
              style: GoogleFonts.notoSerif(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey, // Add a GlobalKey<FormState> _formKey at the top of your State class
              child: AddProductForm(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Products List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey[700],
        onTap: (index) {
          _onItemTapped(index);
          _onItemTappedLogOut(index);
        },
      ),
    );
  }
}
