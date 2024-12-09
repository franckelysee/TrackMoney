import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/utils/app_config.dart';

class CardComponent extends StatefulWidget {
  const CardComponent({super.key, this.color, required this.amount, required this.accountType});
  final Color? color ;
  final double amount;
  final String accountType;
  @override
  State<CardComponent> createState() => _CardComponentState();
}

class _CardComponentState extends State<CardComponent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width - 40,
          height: 200,
          margin: const EdgeInsets.only(bottom: 20, right: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.color ?? const Color(0xFF1A2431),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Montant disponible",
                    style: AppConfig.lightTextStyle,
                  ),
                  const Spacer(),
                  Expanded(
                    child: Text(
                      widget.accountType,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    widget.amount.toString(),
                    style: AppConfig.bigTextStyle,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "USD",
                    style: AppConfig.bigTextStyle,
                  )
                ],
              ),
              Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  "details",
                  style: TextStyle(
                    color: Color(0xFF4A6FCC),
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
        CircularButton(
          icon: Icons.add,
          onpressed: () {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        )
      ],
    );
  }
}
