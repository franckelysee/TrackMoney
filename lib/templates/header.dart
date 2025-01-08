import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppHeader extends StatefulWidget {
  final String title;
  final String? subtitle;


  const AppHeader({super.key, required this.title, this.subtitle});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: null,
      foregroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).cardColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          if (widget.subtitle != null) Text(widget.subtitle!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),),
        ]
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.circleUser),
          onPressed: () {},
        )
      ],
    ) ;
  }
}
