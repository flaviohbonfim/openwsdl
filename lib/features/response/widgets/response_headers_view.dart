import 'package:flutter/material.dart';

class ResponseHeadersView extends StatelessWidget {
  final Map<String, String> headers;

  const ResponseHeadersView({super.key, required this.headers});

  @override
  Widget build(BuildContext context) {
    if (headers.isEmpty) {
      return const Center(child: Text('Nenhum header disponível.'));
    }

    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: headers.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final key = headers.keys.elementAt(index);
        final value = headers[key];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                '$key:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SelectableText(
                  value ?? '',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
