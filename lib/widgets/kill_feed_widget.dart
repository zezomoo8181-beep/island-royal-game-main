import 'package:flutter/material.dart';

class KillFeedWidget extends StatelessWidget {
  final ValueNotifier<List<String>> notifier;
  const KillFeedWidget({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: notifier,
      builder: (_, entries, __) {
        if (entries.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.asMap().entries.map((e) {
            final opacity = 1.0 - (e.key * 0.18);
            return AnimatedOpacity(
              opacity: opacity.clamp(0.2, 1.0),
              duration: const Duration(milliseconds: 400),
              child: Container(
                margin: const EdgeInsets.only(bottom: 3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: e.key == 0
                        ? const Color(0xFFFF6B00).withOpacity(0.5)
                        : Colors.white12,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (e.key == 0)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.close, color: Color(0xFFFF6B00), size: 10),
                      ),
                    Text(
                      e.value,
                      style: TextStyle(
                        color: e.key == 0 ? Colors.white : Colors.white60,
                        fontSize: 11,
                        fontWeight:
                            e.key == 0 ? FontWeight.w700 : FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
