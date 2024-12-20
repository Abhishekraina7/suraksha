import 'package:flutter/material.dart';
import 'package:gosecure/Dashboard/DashWidgets/Cab/Ola.dart';
import 'package:gosecure/Dashboard/DashWidgets/Cab/Rapido.dart';

import 'Cab/Uber.dart';

class BookCab extends StatelessWidget {
  const BookCab({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            UberCard(
              key: UniqueKey(),
            ),
            OlaCard(
              key: UniqueKey(),
            ),
            RadpidoCard(
              key: UniqueKey(),
            )
          ]),
    );
  }
}
