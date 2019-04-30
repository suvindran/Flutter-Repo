import 'package:flutter/material.dart';

class ChipsTile extends StatelessWidget {
  const ChipsTile({
    Key key,
    this.label,
    this.children,
  }) : super(key: key);

  final String label;
  final List<Widget> children;

  // Wraps a list of chips into a ListTile for display as a section in the demo.
  @override
  Widget build(BuildContext context) {
    final List<Widget> cardChildren = <Widget>[
      new Container(
        padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
        alignment: Alignment.center,
        child: new Text(label, textAlign: TextAlign.start),
      ),
    ];
    if (children.isNotEmpty) {
      cardChildren.add(new Wrap(
        children: children.map((Widget chip) {
        return new Padding(
          padding: const EdgeInsets.all(2.0),
          child: chip,
        );
      }).toList()));
    } else {
      final TextStyle textStyle = Theme.of(context).textTheme.caption.copyWith(fontStyle: FontStyle.italic);
      cardChildren.add(
        new Semantics(
          container: true,
          child: new Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
            padding: const EdgeInsets.all(8.0),
            child: new Text('None', style: textStyle),
          ),
        ));
    }

    return new Card(
      //semanticContainer: false,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: cardChildren,
      )
    );
  }
}