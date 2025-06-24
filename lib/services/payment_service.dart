import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload payment proof and create payment record
  Future<String?> uploadPaymentProof({
    required File imageFile,
    required String orderId,
    required String customerName,
    required int totalAmount,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    try {
      // Generate a unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$customerName';
      final ref = _storage.ref().child('payment_proofs').child('$fileName.jpg');

      // Upload the file
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Create payment record in Firestore
      await _firestore.collection('payments').doc(orderId).set({
        'order_id': orderId,
        'customer_name': customerName,
        'amount': totalAmount,
        'payment_proof_url': downloadUrl,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'items': orderItems,
      });

      // Update the order with payment information
      await _firestore.collection('orders').doc(orderId).update({
        'payment_status': 'pending_validation',
        'payment_proof_url': downloadUrl,
        'payment_timestamp': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading payment proof: $e');
      return null;
    }
  }

  // Validate a payment (for admin use)
  Future<bool> validatePayment(String orderId) async {
    try {
      // Update payment record
      await _firestore.collection('payments').doc(orderId).update({
        'status': 'validated',
        'validation_timestamp': FieldValue.serverTimestamp(),
      });

      // Update order status
      await _firestore.collection('orders').doc(orderId).update({
        'payment_status': 'validated',
        'status': 'processing',
      });

      return true;
    } catch (e) {
      debugPrint('Error validating payment: $e');
      return false;
    }
  }

  // Get payment status
  Future<String> getPaymentStatus(String orderId) async {
    try {
      final doc = await _firestore.collection('payments').doc(orderId).get();
      if (doc.exists) {
        return doc.data()?['status'] ?? 'unknown';
      }
      return 'not_found';
    } catch (e) {
      debugPrint('Error getting payment status: $e');
      return 'error';
    }
  }
}
