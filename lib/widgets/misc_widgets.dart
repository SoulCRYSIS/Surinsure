import 'package:flutter/material.dart';

class BlockBorder extends StatelessWidget {
  const BlockBorder({required this.child, this.width = 850, super.key});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      margin: const EdgeInsets.all(10),
      width: width,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: child,
    );
  }
}

class BidirectionScroll extends StatelessWidget {
  const BidirectionScroll({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: child,
      ),
    );
  }
}

const spacing = SizedBox(width: 20);
const spacingVertical = SizedBox(height: 20);

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home),
      onPressed: () => Navigator.of(context).popUntil(ModalRoute.withName('/')),
    );
  }
}
