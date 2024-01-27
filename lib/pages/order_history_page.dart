import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/cart_model.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[200],
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: OrderHistoryList(),
    );
  }
}

class OrderHistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('carts')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(child: Text('No order history available.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var orderData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return OrderHistoryItem(orderData: orderData);
          },
        );
      },
    );
  }
}

class OrderHistoryItem extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderHistoryItem({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract timestamp from orderData
    Timestamp timestamp = orderData['timestamp'];

    // Format timestamp as date and time
    String formattedDateTime = DateFormat('MMM d, yyyy h:mm a').format(timestamp.toDate());

    // Extract list of items from orderData
    List<dynamic> items = orderData['items'];

    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Price: RM${orderData['totalPrice']}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Order Date: $formattedDateTime'),
          SizedBox(height: 8),
          Text('Items:'),
          SizedBox(height: 8),
          // Display the list of items
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]['name']),
                subtitle: Text('Price: RM${items[index]['price']}'),
                // Add more details or customize as needed
              );
            },
          ),
        ],
      ),
    );
  }
}

