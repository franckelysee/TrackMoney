import 'package:flutter/material.dart';
import 'package:trackmoney/templates/header.dart';


class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppHeader(title: 'Categories')),
      body: Center(
        child: Text('Categories'),
      ),
    );
  }
}