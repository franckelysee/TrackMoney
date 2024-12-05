import 'package:flutter/material.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/utils/app_config.dart';

class TransactionCard extends StatefulWidget {
  const TransactionCard({super.key, required this.icon,required this.title, this.iconBackgroundColor, required this.transactionCount, required this.price, required this.priceColor});
  final IconData icon;
  final Color? iconBackgroundColor;
  final Color? priceColor;
  final int transactionCount;
  final double price;
  final String title;
  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: GestureDetector(
          onTap: () {
            // Handle card tap
          },
          child: Card(
            color:  Color(0xFFffffff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 2,
            shadowColor: Colors.grey.withOpacity(0.5),
            child: Container(
              width: MediaQuery.of(context).size.width/2 - 40,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  CircularButton(icon: widget.icon, color: widget.iconBackgroundColor ?? AppConfig.greenbuttonColor, iconColor: Colors.white,),
                  SizedBox(
                    height: 5,
                  ),
                  Text('${widget.transactionCount} transactions', style: TextStyle(fontSize: 14,color: Color.fromRGBO(0, 0, 0, 45) ),),
                  SizedBox( height: 10,),
                  Text(
                    '\$${widget.price}',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.priceColor,
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(widget.title, style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600, color: Colors.black),)
                ]
              ),
            ),
          ),
        ));
  }
}
