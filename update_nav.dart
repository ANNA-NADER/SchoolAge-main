import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  for (var file in dir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;
    String content = file.readAsStringSync();

    if (content.contains('icon: Icon(Icons.public)') || 
        content.contains('icon: const Icon(Icons.public)') || 
        content.contains('icon:Icon(Icons.public)')) {
      continue;
    }

    if (!content.contains('BottomNavigationBar(')) continue;

    if (!content.contains('thematic_map_screen.dart')) {
      final importMatch = RegExp(r'^import .*?;', multiLine: true).allMatches(content);
      if (importMatch.isNotEmpty) {
        final lastImport = importMatch.last.group(0)!;
        content = content.replaceFirst(lastImport, "$lastImport\nimport 'thematic_map_screen.dart';");
      }
    }

    final match = RegExp(r'else if \(index == 2\) \{([^\}]+)\}').firstMatch(content);
    if (match != null) {
      final oldIndex2 = match.group(1)!;
      final newLogic = '''else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ThematicMapScreen()),
            );
          } else if (index == 3) {$oldIndex2}''';
      content = content.replaceFirst(match.group(0)!, newLogic);
    }

    final itemsMatch = RegExp(r'(const\s+)?BottomNavigationBarItem\(').allMatches(content);
    if (itemsMatch.length == 3) {
      final lastItemPos = itemsMatch.last.start;
      final mapItem = "const BottomNavigationBarItem(\n            icon: Icon(Icons.public),\n            label: 'Map',\n          ),\n          ";
      content = content.substring(0, lastItemPos) + mapItem + content.substring(lastItemPos);
    }

    file.writeAsStringSync(content);
    // ignore: avoid_print
    print('Updated ${file.path}');
  }
}
