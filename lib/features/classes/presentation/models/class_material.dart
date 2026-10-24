enum MaterialFileType { pdf, word, excel, link }

class ClassMaterial {
  const new({required this.name, required this.fileType, required this.url});

  final String name;
  final MaterialFileType fileType;
  final String url;
}
