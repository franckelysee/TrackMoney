import 'package:flutter/material.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard(
      {super.key,
      this.icon,
      required this.category,
      this.description,
      required this.onTap,
      this.price,
      this.backgroundColor = Colors.blue})
      ;

  final IconData? icon;
  final String category;
  final String? description;
  final Function() onTap;
  final double? price;
  final Color? backgroundColor ;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.blueGrey,
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: widget.backgroundColor,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, size: 35, color: Colors.white,),
            Spacer(),
            Text(widget.category, style: TextStyle(fontSize: 18,color: Colors.white,)),
            SizedBox(height: 5),
            Text(widget.description?? '', style: TextStyle(fontSize: 14,color: Colors.white,)),
            // SizedBox(height: 5),
            // Row(
            //   children: [
            //     Text('\$${widget.price!.toStringAsFixed(2)}', style: TextStyle(fontSize: 18,color: Colors.white,)),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
