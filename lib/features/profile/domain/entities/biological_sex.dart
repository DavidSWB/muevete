/// Biological sex as chosen by the user. Stored in `users/{uid}.sex` as
/// [storedValue].
enum BiologicalSex {
  male('Male'),
  female('Female');

  const BiologicalSex(this.storedValue);

  final String storedValue;

  /// Reads a stored value. The legacy value "M" reads as [male]; anything
  /// else that is not a stored value reads as null.
  static BiologicalSex? fromStored(String? value) {
    switch (value?.trim()) {
      case 'Male':
      case 'M':
        return BiologicalSex.male;
      case 'Female':
        return BiologicalSex.female;
      default:
        return null;
    }
  }
}
