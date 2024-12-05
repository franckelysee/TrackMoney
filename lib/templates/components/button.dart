import 'package:flutter/material.dart';
import 'package:trackmoney/utils/app_config.dart';

class MyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color? textColor;

  const MyButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CircularButton extends StatefulWidget {
  const CircularButton({super.key, required this.icon, this.iconColor, this.color});
  final IconData icon;
  final Color? iconColor;
  final Color? color;
  @override
  State<CircularButton> createState() => _CircularButtonState();
}

class _CircularButtonState extends State<CircularButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color:widget.color?? AppConfig.greenbuttonColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(widget.icon, color: widget.iconColor?? Colors.white,),
        color: Colors.white,
      ),
    );
  }
}
