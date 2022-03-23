import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/screens/user/home/tabs/home.dart';
import 'package:cleaning_service/screens/user/shared/account/account.dart';
import 'package:cleaning_service/screens/user/shared/notification.dart';
import 'package:cleaning_service/screens/user/shared/status.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserHomeScreen extends StatefulWidget {
  final int pageIndex;
  UserHomeScreen({
    Key? key,
    this.pageIndex = 0,
  }) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentPage = 0;

  _tabs(int index) {
    final _t = [
      UserHomeTabScreen(
        onChangePage: (i) {
          setState(() {
            _currentPage = i;
          });
        },
      ),
      StatusTabScreen(),
      NotificationTabScreen(),
      AccountScreen(),
    ];

    return _t[index];
  }

  @override
  initState() {
    _currentPage = widget.pageIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs(_currentPage),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.box),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            label: 'Notifications',
            icon: FaIcon(FontAwesomeIcons.solidBell),
            // icon: Container(
            //   width: 40,
            //   child: Stack(
            //     children: [
            //       FaIcon(FontAwesomeIcons.solidBell),
            //       Positioned(
            //         top: 0.0,
            //         right: 5.0,
            //         child: Container(
            //           width: 20,
            //           height: 20,
            //           decoration: BoxDecoration(
            //             color: Colors.red,
            //             borderRadius: BorderRadius.circular(99),
            //           ),
            //           child: Center(
            //             child: Text(
            //               "1",
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 12,
            //               ),
            //               overflow: TextOverflow.ellipsis,
            //             ),
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidUser),
            label: 'Account',
          ),
        ],
        currentIndex: _currentPage,
        showSelectedLabels: false,
        selectedItemColor: kPurple,
        unselectedItemColor: Colors.grey[400],
        onTap: (page) {
          setState(() {
            _currentPage = page;
          });
        },
      ),
    );
  }
}
