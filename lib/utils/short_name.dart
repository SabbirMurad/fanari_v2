part of '../utils.dart';

String getShortName(String name) {
  final List<String> attributes = [
    "md",
    "Md",
    "Md.",
    "md.",
    "MD",
    "MD.",
    "Mst",
    "Mst.",
    "mst.",
    "MST",
    "MST.",
    "mst.",
    "Dr",
    "Dr.",
    "dr.",
    "DR",
    "DR.",
    "dr.",
    "Prof",
    "Prof.",
    "prof.",
    "PROF",
    "PROF.",
    "prof.",
    "PhD",
    "PhD.",
    "phd.",
    "PhD",
    "PhD.",
    "phd.",
  ];

  List<String> split = name.split(" ");

  if (attributes.contains(split[0])) {
    if (split.length < 2) {
      return split[0];
    } else {
      return '${split[0]} ${split[1]}';
    }
  } else {
    return split[0];
  }
}
