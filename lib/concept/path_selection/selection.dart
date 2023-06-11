import 'selection_action.dart';

class Selection {
  final List<String> selectedPaths;
  final SelectionAction action;

  const Selection({required this.selectedPaths, required this.action});
}
