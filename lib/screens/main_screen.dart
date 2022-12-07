import 'package:flutter/material.dart';
import 'package:woot/screens/customer_form_screen.dart';
import 'package:woot/widgets/form_widgets.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Menu',
            style: Theme.of(context).textTheme.headline1,
          ),
          spacingVertical,
          BlockBorder(
            width: 500,
            child: Column(
              children: [
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerFormScreen(),
                      ),
                    ),
                    child: const Text('ลงทะเบียนลูกค้า'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
