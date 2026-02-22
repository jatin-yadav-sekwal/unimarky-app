import 'package:flutter/material.dart';
import 'package:unimarky/features/food/screens/food_list_screen.dart';
import 'package:unimarky/features/housing/screens/housing_list_screen.dart';
import 'package:unimarky/features/study/screens/study_list_screen.dart';

class ExploreScreen extends StatelessWidget {
  final int initialIndex;
  const ExploreScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: 'Food'),
              Tab(icon: Icon(Icons.apartment), text: 'Housing'),
              Tab(icon: Icon(Icons.school), text: 'Study'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FoodListScreen(),
            HousingListScreen(),
            StudyListScreen(),
          ],
        ),
      ),
    );
  }
}
