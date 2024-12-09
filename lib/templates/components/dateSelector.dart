import 'package:flutter/material.dart';
import 'package:trackmoney/utils/app_config.dart';


class Dateselector extends StatefulWidget {
  const Dateselector({super.key});

  @override
  State<Dateselector> createState() => _DateselectorState();
}

class _DateselectorState extends State<Dateselector> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width ,
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color:Theme.of(context).colorScheme.surface ),
              child: Icon(Icons.chevron_left),
            ),

            TextButton(
              onPressed: () async {
                final DateTime? dateTime = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(3000));
                if (dateTime != null) {
                  setState(() {
                    selectedDate = dateTime;
                  });
                }
              },
              child: Row(
                children: [
                  Icon(Icons.calendar_month),
                  SizedBox(
                    width: 1,
                  ),
                  Text("${selectedDate.year} - ${selectedDate.month} - ${selectedDate.day}"),
                  SizedBox(width: 5,),
                  Icon(Icons.arrow_drop_down)
                ],
              ),
            ),

            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).colorScheme.surface),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),

    );
  }
}