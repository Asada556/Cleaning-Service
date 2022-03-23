import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/screens/maid/home/tabs/home.dart';
import 'package:cleaning_service/screens/maid/home/tabs/job.dart';
import 'package:cleaning_service/screens/user/shared/account/account.dart';
import 'package:cleaning_service/screens/user/shared/notification.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MaidHomeScreen extends StatefulWidget {
  final int pageIndex;
  MaidHomeScreen({
    Key? key,
    this.pageIndex = 0,
  }) : super(key: key);

  @override
  State<MaidHomeScreen> createState() => _MaidHomeScreenState();
}

class _MaidHomeScreenState extends State<MaidHomeScreen> {
  int _currentPage = 0;

  @override
  initState() {
    _currentPage = widget.pageIndex;
    super.initState();
  }

  _tabs(int index) {
    final _t = [
      MaidrHomeTabScreen(
        onChangePage: (i) {
          setState(() {
            _currentPage = i;
          });
        },
      ),
      MaidJobScreen(),
      NotificationTabScreen(),
      AccountScreen(),
    ];

    return _t[index];
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
            icon: FaIcon(FontAwesomeIcons.solidBell),
            label: 'Notifications',
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
