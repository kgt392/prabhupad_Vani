class Kirtan {
  final String id;            // unique id or filename
  final String title;         // kirtan/bhajan name
  final String type;          // e.g. Bhajan, Kirtan, Japa
  final String audioPath;     // asset path
  final String? date;         // optional
  final String? location;     // optional

  const Kirtan({
    required this.id,
    required this.title,
    required this.type,
    required this.audioPath,
    this.date,
    this.location,
  });
}


