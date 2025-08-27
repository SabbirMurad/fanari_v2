import 'package:flutter/material.dart';

class SecondaryAppBar extends StatelessWidget {
  final String title;

  const SecondaryAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
            blurRadius: 4.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 3.0),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            padding: const EdgeInsets.all(0.0),
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Image(
              image: const AssetImage('assets/icons/arrow_back.png'),
              width: 24,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
