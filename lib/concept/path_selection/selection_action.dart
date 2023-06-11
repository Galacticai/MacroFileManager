enum SelectionAction {
  copy("Copy"),
  paste("Paste"),
  rename("Rename"),
  delete("Delete"),
  properties("Properties");

  final String name;
  const SelectionAction(this.name);
}
