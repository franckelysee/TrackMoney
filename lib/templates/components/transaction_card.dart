import 'package:flutter/material.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/utils/app_config.dart';
import 'package:trackmoney/utils/currency_utils.dart';

class TransactionCard extends StatefulWidget {
  const TransactionCard(
      {super.key,
      required this.icon,
      required this.title,
      this.iconBackgroundColor,
      required this.transactionCount,
      required this.price,
      required this.priceColor,
      this.onTap});
  final IconData icon;
  final Color? iconBackgroundColor;
  final Color? priceColor;
  final int transactionCount;
  final double price;
  final String title;
  final VoidCallback? onTap;
  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  String _formattedPrice = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      final formattedAmount = await CurrencyUtils.formatAmount(
        widget.price,
        showSign: false,
      );

      if (mounted) {
        setState(() {
          _formattedPrice = formattedAmount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _formattedPrice = '${widget.price} FCFA';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Card(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 2,
            shadowColor: Color.fromRGBO(158, 158, 158, 0.5),
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 40,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularButton(
                      icon: widget.icon,
                      color: widget.iconBackgroundColor ??
                          AppConfig.greenbuttonColor,
                      iconColor: Colors.white,
                      onpressed: () {

                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${widget.transactionCount} transactions',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.priceColor ?? Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Text(
                          _formattedPrice,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.priceColor,
                          ),
                        ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ]),
            ),
          ),
        ));
  }
}
