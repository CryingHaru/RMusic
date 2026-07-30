import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppMemoryLogOutput extends LogOutput {
  final int maxLines;
  final OutputEventListNotifier eventsNotifier = OutputEventListNotifier();

  AppMemoryLogOutput({this.maxLines = 1000});

  @override
  void output(OutputEvent event) {
    eventsNotifier.add(event, maxLines: maxLines);
  }

  void clear() {
    eventsNotifier.clearEvents();
  }
}

class OutputEventListNotifier extends ChangeNotifier
    implements ValueListenable<List<OutputEvent>> {
  final List<OutputEvent> _events = <OutputEvent>[];

  @override
  List<OutputEvent> get value => _events;

  void add(OutputEvent event, {required int maxLines}) {
    if (_events.length >= maxLines) {
      _events.removeAt(0);
    }
    _events.add(event);
    notifyListeners();
  }

  void clearEvents() {
    if (_events.isEmpty) return;
    _events.clear();
    notifyListeners();
  }
}
