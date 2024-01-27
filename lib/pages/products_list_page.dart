import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id; // Add this line to store the document ID
  final String name;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class ProductsListPage extends StatefulWidget {
  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

Future<List<Product>> fetchProducts() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
    final products = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Product(
        id: doc.id, // Store the document ID
        name: data['name'],
        price: data['price'].toDouble(),
        imageUrl: data['imageUrl'],
      );
    }).toList();
    return products;
  } catch (e) {
    print('Error fetching products: $e');
    return [];
  }
}

class _ProductsListPageState extends State<ProductsListPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final List<Product> fetchedProducts = await fetchProducts();
    setState(() {
      products = fetchedProducts;
    });
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false; // Add this line to handle null and default to false
  }

  Future<void> _deleteProduct(Product product, BuildContext context) async {
    bool confirmDelete = await _showDeleteConfirmationDialog(context);

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(product.id)
            .delete();

        _showSuccessDialog(context, 'Product deleted successfully');

        _fetchProducts(); // Refresh the product list after deletion
      } catch (e) {
        print('Error deleting product: $e');
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200],
      appBar: AppBar(
        title: Text('Products List'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... Other UI elements

          // List of Products
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(products[index].name),
                  subtitle: Text('Price: ${products[index].price}'),
                  leading: Container(
                    width: 50.0,
                    height: 50.0,
                    child: Image.network(
                      products[index].imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteProduct(products[index], context);
                    },
                  ),
                  // Add more details or customize as needed
                );
              },
            ),
          ),
        ],
      ),
      // ... BottomNavigationBar or other components
    );
  }
}

