import 'package:flutter/material.dart';

import 'search_metadata.dart';

class FiltersFooterView extends StatelessWidget {
  const FiltersFooterView(
      {super.key, required this.metadata, required this.onClear});

  final Stream<SearchMetadata> metadata;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColorLight,
                side: const BorderSide(
                    width: 1.0,
                    color: Color(0xFF21243D),
                    style: BorderStyle.solid)
              ),
              child: const Text(
                "Clear Filters",
                textAlign: TextAlign.center,
              )),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: StreamBuilder<SearchMetadata>(
              stream: metadata,
              builder: (context, snapshot) {
                final String nbHits;
                if (snapshot.hasData) {
                  nbHits = ' ${snapshot.data!.nbHits} ';
                } else {
                  nbHits = '';
                }
                return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF21243D)),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "See $nbHits Products",
                      textAlign: TextAlign.center,
                    ));
              },
            )),
      ],
    );
  }
}
