import 'package:flutter/material.dart';

class GuildScreen extends StatelessWidget {
  const GuildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guild'),
      ),
      body: const Center(
        child: Text('Guild Screen'),
      ),
    );
  }
}
