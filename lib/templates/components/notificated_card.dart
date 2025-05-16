import 'package:flutter/material.dart';
import 'package:trackmoney/utils/currency_utils.dart';

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
      this.onLongPress});
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
  final DateTime? date;
  final void Function()? onTap;
  final void Function()? onLongPress;
  @override
  State<NotificatedCard> createState() => _NotificatedCardState();
}

class _NotificatedCardState extends State<NotificatedCard> {
  String? _formattedPrice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    if (widget.price != null) {
      final formattedAmount = await CurrencyUtils.formatAmount(
        widget.price!,
        showSign: true,
      );

      if (mounted) {
        setState(() {
          _formattedPrice = formattedAmount;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Formater la date pour un affichage plus lisible
    String formattedDate = "";
    if (widget.date != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final dateToCheck = DateTime(widget.date!.year, widget.date!.month, widget.date!.day);

      if (dateToCheck == today) {
        formattedDate = "Aujourd'hui à ${widget.date!.hour.toString().padLeft(2, '0')}:${widget.date!.minute.toString().padLeft(2, '0')}";
      } else if (dateToCheck == yesterday) {
        formattedDate = "Hier à ${widget.date!.hour.toString().padLeft(2, '0')}:${widget.date!.minute.toString().padLeft(2, '0')}";
      } else {
        const monthNames = [
          'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
          'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
        ];
        formattedDate = "${widget.date!.day} ${monthNames[widget.date!.month - 1]} à ${widget.date!.hour.toString().padLeft(2, '0')}:${widget.date!.minute.toString().padLeft(2, '0')}";
      }
    }

    return InkWell(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Card(
          color: widget.backgroundColor ?? (isDarkMode
              ? theme.colorScheme.surfaceContainerLow
              : theme.cardColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icône avec fond coloré
                if (widget.icon != null)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.iconBackgroundColor ?? theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isDarkMode ? [] : [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor ?? Colors.white,
                      size: 22,
                    ),
                  ),
                SizedBox(width: 16),

                // Titre et sous-titre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: widget.titleSize,
                          fontWeight: FontWeight.w600,
                          color: widget.textColor ??
                              (isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ),
                      SizedBox(height: 4),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: widget.subtitleSize ?? 14,
                            color: widget.textColor != null
                                ? widget.textColor!
                                : (isDarkMode ? Colors.grey[300] : Colors.grey[600]),
                          ),
                        ),
                      if (widget.date != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Prix
                if (widget.price != null)
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.price! > 0
                          ? (isDarkMode
                              ? Color(0xFF1B5E20).withAlpha(60) // Vert foncé en mode sombre
                              : Colors.green.withAlpha(30))
                          : (isDarkMode
                              ? Color(0xFFB71C1C).withAlpha(60) // Rouge foncé en mode sombre
                              : Colors.red.withAlpha(30)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.price! > 0
                              ? (isDarkMode ? Color(0xFF81C784) : Colors.green)
                              : (isDarkMode ? Color(0xFFEF9A9A) : Colors.red),
                          ),
                        )
                      : Text(
                          _formattedPrice ?? '${widget.price! > 0 ? "+" : ""}${widget.price} FCFA',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.price! > 0
                                ? (isDarkMode ? Color(0xFF81C784) : Colors.green) // Vert plus clair en mode sombre
                                : (isDarkMode ? Color(0xFFEF9A9A) : Colors.red),  // Rouge plus clair en mode sombre
                          ),
                        ),
                  ),

                // Élément trailing (optionnel)
                if (widget.trailing != null)
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: widget.trailing,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
