part of '../utils.dart';

/// Returns a display-friendly short version of a full [name].
///
/// If the name starts with a known title prefix (e.g. "Dr.", "Prof."), the
/// first two tokens are kept; otherwise only the first name is returned.
String get_short_name(String name) {
  const title_prefixes = {
    'md', 'md.', 'mst', 'mst.',
    'dr', 'dr.',
    'prof', 'prof.',
    'phd', 'phd.',
  };

  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return name;

  final first_lower = parts.first.toLowerCase();

  if (title_prefixes.contains(first_lower)) {
    return parts.length > 1 ? '${parts[0]} ${parts[1]}' : parts[0];
  }

  return parts.first;
}
