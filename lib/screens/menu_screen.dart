import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:woot/screens/search_customers_screen.dart';
import 'package:woot/screens/customer_form_screen.dart';
import 'package:woot/screens/search_policies_screen.dart';
import 'package:woot/screens/search_properties_screen.dart';
import 'package:woot/utils/server_data.dart';

import '../utils/ui_util.dart';
import '../widgets/misc_widgets.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      UiUtil.loadingScreen(context,
          timeoutSecond: 3, future: ServerData.fetchData());
    });
    super.initState();
  }

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
                            builder: (context) => const SearchCustomersScreen(),
                          ),
                        ),
                        child: const Text('ข้อมูลลูกค้า'),
                      ),
                    ),
                    spacingVertical,
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SearchPropertiesScreen(),
                          ),
                        ),
                        child: const Text('ข้อมูลทรัพย์สิน'),
                      ),
                    ),
                    spacingVertical,
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchPoliciesScreen(),
                          ),
                        ),
                        child: const Text('ข้อมูลกรมธรรม์'),
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
