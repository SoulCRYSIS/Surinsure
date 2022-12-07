import 'package:flutter/material.dart';
import 'package:woot/screens/all_customers_screen.dart';
import 'package:woot/screens/customer_form_screen.dart';
import 'package:woot/widgets/form_widgets.dart';


class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BidirectionScroll(
          child: Column(
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
                            builder: (context) => const CustomerFormScreen(),
                          ),
                        ),
                        child: const Text('ลงทะเบียนลูกค้าใหม่'),
                      ),
                    ),
                    spacingVertical,
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllCustomersScreen(),
                          ),
                        ),
                        child: const Text('ข้อมูลลูกค้า'),
                      ),
                    ),
                  ],
                ),
              ),
              spacingVertical,
              const Text(
                'เกิดปัญหาขัดข้อง โทร. 097-238-5152',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
