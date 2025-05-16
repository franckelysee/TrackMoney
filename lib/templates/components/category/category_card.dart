import 'package:flutter/material.dart';
import 'package:trackmoney/utils/currency_utils.dart';

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
  String _formattedPrice = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.price != null) {
      _loadCurrency();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadCurrency() async {
    try {
      final formattedAmount = await CurrencyUtils.formatAmount(
        widget.price!,
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
          _formattedPrice = '${widget.price!.toStringAsFixed(0)} FCFA';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor!.withAlpha(70),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône avec fond semi-transparent
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            Spacer(),
            // Nom de la catégorie
            Text(
              widget.category,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            // Description (si disponible)
            if (widget.description != null && widget.description!.isNotEmpty)
              Text(
                widget.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(204), // ~80% d'opacité
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            // Prix (si disponible)
            if (widget.price != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(77), // ~30% d'opacité
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: _isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _formattedPrice,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
