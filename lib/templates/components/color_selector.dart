import 'package:flutter/material.dart';


class ColorSelector {

  final List<Color> colors = [
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.purple,
    Color(0xFF242760),
    Colors.indigo,
    Color(0xFF6E73C4),
    Colors.blue,
    Colors.green,
    Colors.teal,
    Colors.brown,
    // Add more colors here if needed
  ];


  Future <Color?> showColorSelector(BuildContext context) async {
    return showModalBottomSheet(context: context, 
    
    backgroundColor: Colors.grey,
      builder: (context) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).pop(colors[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colors[index],
                ),
              ),
            );
          },
        );
      });
  }
  
}