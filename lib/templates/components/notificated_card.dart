import 'package:flutter/material.dart';

class NotificatedCard extends StatefulWidget {
  const NotificatedCard(
      {super.key,
      this.icon,
      required this.title,
      required this.titleSize,
      required this.subtitle,
      this.subtitleSize,
      this.backgroundColor,
      this.textColor,
      this.price,
      this.iconColor,
      this.image,
      this.iconBackgroundColor,
      this.date
      }
    );
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final double titleSize;
  final String subtitle;
  final double? subtitleSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double? price;
  final Image? image;
  final int? date;
  @override
  State<NotificatedCard> createState() => _NotificatedCardState();
}

class _NotificatedCardState extends State<NotificatedCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Handle card tap
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Card(
            color: widget.backgroundColor ?? Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shadowColor: Colors.grey.withOpacity(0.5),
            elevation: 2,
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                if (widget.icon != null)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.iconBackgroundColor ?? Color(0xFF3273EC),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Theme.of(context).cardColor, width: 1),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor ?? Colors.white,
                    ),
                  ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: widget.titleSize,
                        fontWeight: FontWeight.w600,
                        color: widget.textColor ?? Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: widget.subtitleSize ?? 14,
                        color: widget.textColor ?? Color(0xFF727272),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    if (widget.price != null)
                      Text(
                        '\$${widget.price}',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.price! > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    if (widget.date != null)
                      Text("${widget.date}")
                  ],
                )
              ]),
            ),
          ),
        ));
  }
}
