import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'How do I place an order?',
      answer:
          'Browse restaurants or search for specific foods, add items to your cart, enter delivery address, and proceed to checkout. Payment options include card and digital wallets.',
    ),
    FAQItem(
      question: 'How can I track my order?',
      answer:
          'Once your order is confirmed, you can track it in real-time from your Order History. You\'ll see the restaurant preparing your food and the delivery driver\'s location.',
    ),
    FAQItem(
      question: 'What is your delivery time?',
      answer:
          'Delivery times vary by restaurant and location, typically ranging from 20-45 minutes. The estimated time is shown before you place your order.',
    ),
    FAQItem(
      question: 'Can I modify my order after placing it?',
      answer:
          'You can modify your order within 2 minutes of placing it. After that, contact our support team immediately to see if changes are possible.',
    ),
    FAQItem(
      question: 'What is the minimum order value?',
      answer:
          'Minimum order value varies by restaurant. Most restaurants have a minimum of 100 AED. Check the restaurant details for specific minimums.',
    ),
    FAQItem(
      question: 'Do you offer refunds?',
      answer:
          'Yes, we offer full refunds for cancelled orders or if the restaurant cannot fulfill your order. Refunds are processed within 3-5 business days.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Contact Section
            _buildQuickContactSection(),
            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 16),
            ..._buildFAQList(),
            const SizedBox(height: 32),

            // Contact Support Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showContactDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need Quick Help?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactOption(
            icon: Icons.phone,
            label: 'Call Us',
            value: '+971 4 343 6767',
            onTap: () => _launchPhone('+97144444444'),
          ),
          const SizedBox(height: 12),
          _buildContactOption(
            icon: Icons.email,
            label: 'Email Us',
            value: 'support@chikibite.com',
            onTap: () => _launchEmail('support@chikibite.com'),
          ),
          const SizedBox(height: 12),
          _buildContactOption(
            icon: Icons.chat,
            label: 'Live Chat',
            value: 'Available 9 AM - 10 PM',
            onTap: () => _showChatDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFAQList() {
    return faqItems
        .map((item) => _buildFAQItem(item))
        .toList()
        .expand((widget) => [widget, const SizedBox(height: 12)])
        .toList();
  }

  Widget _buildFAQItem(FAQItem item) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      backgroundColor: Colors.grey[50],
      collapsedBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            item.answer,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'Choose your preferred method to contact us:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to our support team...'),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Support Request'},
    );
    await launchUrl(emailLaunchUri);
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
