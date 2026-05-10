/// Stage 2 production storage is represented by repository/data-source
/// boundaries. This implementation uses SharedPreferences JSON so the app is
/// runnable without code generation. The same interfaces can be backed by Drift
/// tables in a later migration without touching presentation controllers.
class StorageNotes {
  const StorageNotes._();
}
