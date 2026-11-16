enum MaterialFileType {
  pdf,
  word,
  excel,
  powerpoint,
  image,
  text,
  file,
  link;

  bool get isOffice => this == word || this == excel || this == powerpoint;
}

class ClassMaterial {
  const new({required this.name, required this.fileType, required this.url});

  final String name;
  final MaterialFileType fileType;
  final String url;
}
