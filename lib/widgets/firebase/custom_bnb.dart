import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/index.dart';
import '../../models/app_model.dart';
import '../../models/cart/cart_base.dart';
import '../icons/feather.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  List<BottomNavigationBarItem> navBarList(context) {
    List<BottomNavigationBarItem> list = [];
    int index = 0;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    var totalCart = Provider.of<CartModel>(context).totalCartQuantity;
    final tabData = Provider.of<AppModel>(context, listen: false)
        .appConfig!['TabBar'] as List;

    final appSetting = Provider.of<AppModel>(context).appConfig!['Setting'];
    final colorIcon = appSetting['TabBarIconColor'] != null
        ? HexColor(appSetting['TabBarIconColor'])
        : Theme.of(context).colorScheme.secondary;

    final activeColorIcon = appSetting['ActiveTabBarIconColor'] != null
        ? HexColor(appSetting['ActiveTabBarIconColor'])
        : Theme.of(context).primaryColor;
    tabData.forEach((item) {
      const isActive = false;
      var icon = !item["icon"].contains('/')
          ? Icon(
        featherIcons[item["icon"]],
        color: isActive ? activeColorIcon : colorIcon,
        size: 22,
      )
          : (item["icon"].contains('http')
          ? Image.network(
        item["icon"],
        color: isActive ? activeColorIcon : colorIcon,
        width: 24,
      )
          : Image.asset(
        item["icon"],
        color: isActive ? activeColorIcon : colorIcon,
        width: 24,
      ));

      if (item["layout"] == "cart") {
        icon = Stack(
          children: <Widget>[
            Container(
              width: 30,
              height: 25,
              padding: const EdgeInsets.only(right: 0.0, top: 0),
              child: icon,
            ),
            if (totalCart > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    totalCart.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 14 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        );
      }

      if (item["label"] != null) {
        list.add(BottomNavigationBarItem(
          icon: icon,
          label: item["label"],
        ));
      } else {
        list.add(BottomNavigationBarItem(icon: icon, label: ""));
      }
      index++;
    });

    return list;
  }
}
