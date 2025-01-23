import 'package:flutter/material.dart';

class NotificatedCard extends StatefulWidget {
  const NotificatedCard(
      {super.key,
      this.icon,
      required this.title,
      required this.titleSize,
      this.subtitle,
      this.subtitleSize,
      this.trailing,
      this.backgroundColor,
      this.textColor,
      this.price,
      this.iconColor,
      this.image,
      this.iconBackgroundColor,
      this.date,
      this.onTap,
      this.onLongPress
      }
    );
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final Widget? trailing;
  final double titleSize;
  final String? subtitle;
  final double? subtitleSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double? price;
  final Image? image;
  final int? date;
  final void Function()? onTap;
  final void Function()? onLongPress;
  @override
  State<NotificatedCard> createState() => _NotificatedCardState();
}

class _NotificatedCardState extends State<NotificatedCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap:widget.onTap,
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
              width: double.infinity,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        // overflow: TextOverflow.ellipsis,
                        // softWrap: true,
                        style: TextStyle(
                          fontSize: widget.titleSize,
                          fontWeight: FontWeight.w600,
                          color: widget.textColor ?? Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if(widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          fontSize: widget.subtitleSize ?? 14,
                          color: widget.textColor ?? Color(0xFF727272),
                        ),
                      ),
                    ],
                  ),
                ),
                if(widget.price !=null)
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
                ),
                if (widget.trailing!= null)
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: widget.trailing,
                ),
                // Container(
                //   width: 8,
                //   height: 8,
                //   decoration: BoxDecoration(
                //     color: Colors.red,
                //     borderRadius: BorderRadius.circular(50)
                //   ),
                // )
              ]),
            ),
          ),
        ));
  }
}
