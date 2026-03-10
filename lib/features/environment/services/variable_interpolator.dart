import 'dart:math';
import 'package:uuid/uuid.dart';

class VariableInterpolator {
  static final RegExp _variableRegex = RegExp(r'\{\{([^\}]+)\}\}');
  static const _uuid = Uuid();

  /// Interpolates variables in the given [text] using the [variables] map.
  /// Supports recursive substitution and dynamic variables like {{$guid}}, {{$timestamp}}.
  static String interpolate(String text, Map<String, String> variables, {int maxDepth = 10}) {
    if (text.isEmpty) return text;
    
    String result = text;
    int depth = 0;

    while (depth < maxDepth) {
      final matches = _variableRegex.allMatches(result).toList();
      if (matches.isEmpty) break;

      bool changed = false;
      // We process from right to left to avoid index shifts during replacement
      for (var i = matches.length - 1; i >= 0; i--) {
        final match = matches[i];
        final fullMatch = match.group(0)!;
        final variableName = match.group(1)!.trim();

        String? replacement;
        
        // Check dynamic variables
        if (variableName.startsWith('\$')) {
          replacement = _getDynamicVariable(variableName);
        } else {
          replacement = variables[variableName];
        }

        if (replacement != null) {
          result = result.replaceRange(match.start, match.end, replacement);
          changed = true;
        }
      }

      if (!changed) break;
      depth++;
    }

    return result;
  }

  static String? _getDynamicVariable(String name) {
    switch (name.toLowerCase()) {
      case r'$guid':
        return _uuid.v4();
      case r'$timestamp':
        return DateTime.now().millisecondsSinceEpoch.toString();
      case r'$isoTimestamp':
        return DateTime.now().toIso8601String();
      case r'$randomint':
        return Random().nextInt(1000).toString();
      default:
        return null;
    }
  }
}
