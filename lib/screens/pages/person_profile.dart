import 'package:briio_application/screens/pages/savedaddress.dart';
import 'package:briio_application/screens/pages/update_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../controller/auth_controller.dart';
import '../../utils/globel_veriable.dart';
import '../auth/sign_in.dart';
import 'customorder_history.dart';
import 'order_history.dart';
import 'package:briio_application/screens/pages/terms_conditions.dart';
import 'package:briio_application/screens/pages/about_us.dart';
import 'package:briio_application/screens/pages/privacy_policy.dart';
import 'package:briio_application/screens/pages/customer_care.dart';
import 'package:briio_application/screens/pages/bank_details.dart';

class PersonProfile extends StatefulWidget {
  const PersonProfile({Key? key}) : super(key: key);

  @override
  State<PersonProfile> createState() => _PersonProfileState();
}

class _PersonProfileState extends State<PersonProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        clipBehavior: Clip.none,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 1,
        title: Text('PROFILE',
          style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  style: BorderStyle.solid
                ),
                borderRadius: BorderRadius.circular(10.0),
                image: const DecorationImage(
                    image: AssetImage('assets/blg.png'), opacity: 0.08),
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 20),
                      Icon(
                        CupertinoIcons.person_alt_circle,
                        size: 100,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${GlobalK.companyName}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${GlobalK.userFName}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                            Text(
                                '${GlobalK.address},${GlobalK.city},${GlobalK.state}'),
                            Text(
                              '+${GlobalK.phone}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Image.asset(
                        'assets/edit_icon.png',
                        width: 20,
                        height: 20,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () async {
                        final result = await Get.to(() => const UpdateProfileScreen());
                        if (result == true) {
                          // Force rebuild of PersonProfile
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.shopping_bag,
                  color: Colors.black45,
                ),
                title: const Text('Order History'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () {
                  if (GlobalK.userId == null) {
                    Get.offAll(() => const SignIn());
                  } else {
                    Get.to(() => const OrderHistoryPage());
                  }
                },
              ),
            ),
            Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.dashboard_customize,
                  color: Colors.black45,
                ),
                title: const Text('Custom Order History'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () {
                  if (GlobalK.userId == null) {
                    Get.offAll(() => const SignIn());
                  } else {
                    Get.to(() => const CustomOrderHistory());
                  }
                },
              ),
            ),
            Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.location_city,
                  color: Colors.black45,
                ),
                title: const Text('Saved Addresses'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () => Get.to(() => const SavedAddress(
                    forOrder: false,
                    instruction: '',
                )),
              ),
            ),
            Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.group,
                  color: Colors.black45,
                ),
                title: const Text('About Us'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () => Get.to(() => const AboutUs()),
                // onTap: () => launchUrl(Uri.parse('https://briio.in/')),
              ),
            ),
            Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.security,
                  color: Colors.black45,
                ),
                title: const Text('Privacy Policy'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () => Get.to(() => const PrivacyPolicy()),
              ),
            ),
        
            Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.security,
                  color: Colors.black45,
                ),
                title: const Text('Terms & Conditions'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () => Get.to(() => const TermsConditions()),
              ),
            ),
              Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance,
                  color: Colors.black45,
                ),
                title: const Text('Bank Details'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () => Get.to(() => const BankDetails()),
              ),
            ),
            Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.support_agent,
                  color: Colors.black45,
                ),
                title: const Text('Customer Care'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () => Get.to(() => const CustomerCare()),
              ),
            ),
            Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.black45,
                ),
                title: const Text('Logout'),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () {
                  Get.defaultDialog(
                    backgroundColor: Colors.white,
                    title: 'Confirm Logout',
                    middleText: 'Are you sure you want to logout?',
                    confirm: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                      onPressed: () => AuthLogin.logout(),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    cancel: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
