// MyTabBar.dart
import 'package:flutter/material.dart';

PreferredSizeWidget MyTabBar(TabController controller, BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(48),
    child: Container(
      alignment: Alignment.center,
      child: TabBar(

        dividerHeight: 0.2,
        indicatorWeight: 1.0,
        controller: controller,
        tabs: const [
          Tab(text: "Chats"),
          Tab(text: "Groups"),
          Tab(text: "Calls"),
          // Tab(text: 'Missed Calls'),
          // Tab(text: 'Archived'),
        ],
        labelStyle: Theme.of(context).textTheme.bodySmall,
        unselectedLabelStyle: Theme.of(context).textTheme.labelSmall,
        splashBorderRadius: BorderRadius.circular(10),
        indicatorColor: Theme.of(context).colorScheme.primary,
        dividerColor: Colors.transparent,
        
      ),
    ),
  );
}
