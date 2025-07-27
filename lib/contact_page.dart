import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mbilalpk56@gmail.com',
      query: 'subject=Blood Bank Inquiry',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch email app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+923216412855');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchMap() async {
    final Uri mapUri = Uri.parse(
      'https://maps.google.com/?q=123+Main+Street+City+State+12345',
    );
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch map app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Message sent successfully! We'll get back to you soon.",
            ),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: \\${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.contact_support,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Get in Touch',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We are here to help you. Reach out for any queries or support.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  child: ListTile(
                    leading: Icon(Icons.email, color: Colors.white),
                    title: const Text(
                      'Email',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'mbilalpk56@gmail.com',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _launchEmail,
                      tooltip: 'Send Email',
                    ),
                  ),
                ),
                Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  child: ListTile(
                    leading: Icon(Icons.phone, color: Colors.white),
                    title: const Text(
                      'Phone',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      '03216412855',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: Colors.white),
                      onPressed: _launchPhone,
                      tooltip: 'Call',
                    ),
                  ),
                ),
                Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  child: ListTile(
                    leading: Icon(Icons.location_on, color: Colors.white),
                    title: const Text(
                      'Address',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      '123 Main Street\nCity, State 12345',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.map, color: Colors.white),
                      onPressed: _launchMap,
                      tooltip: 'Open in Maps',
                    ),
                  ),
                ),
                Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  child: ListTile(
                    leading: Icon(Icons.access_time, color: Colors.white),
                    title: const Text(
                      'Operating Hours',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Mon-Fri: 9am - 6pm\nSat: 10am - 4pm',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your email'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.subject,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a subject'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your message'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Send Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isLoading ? null : _submitForm,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.emergency, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Emergency Contact:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+92 321 6412855',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
