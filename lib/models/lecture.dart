// class Lecture {
//   final String title;
//   final String book;
//   final String date;
//   final String location;
//   final String audioPath;
//   final String? transcript;

//   Lecture({
//     required this.title,
//     required this.book,
//     required this.date,
//     required this.location,
//     required this.audioPath,
//     this.transcript,
//   });
// }

// class TranscriptLine {
//   final Duration time; // timestamp in the audio
//   final String text;   // transcript text at this time

//   TranscriptLine({required this.time, required this.text});

//   factory TranscriptLine.fromMap(Map<String, dynamic> map) {
//     return TranscriptLine(
//       time: Duration(seconds: map['time']),
//       text: map['text'],
//     );
//   }
// }

// class Lecture {
//   final String title;
//   final String book;
//   final String date;
//   final String location;
//   final String audioPath;
//   final List<TranscriptLine>? transcript; // optional transcript lines

//   Lecture({
//     required this.title,
//     required this.book,
//     required this.date,
//     required this.location,
//     required this.audioPath,
//     this.transcript,
//   });

//   factory Lecture.fromMap(Map<String, dynamic> map) {
//     return Lecture(
//       title: map['title'],
//       book: map['book'],
//       date: map['date'],
//       location: map['location'],
//       audioPath: map['audioPath'],
//       transcript: map['transcript'] != null
//           ? (map['transcript'] as List)
//               .map((e) => TranscriptLine.fromMap(e))
//               .toList()
//           : null,
//     );
//   }
// }
class TranscriptLine {
  final Duration time; // timestamp in the audio
  final String text;   // transcript text at this time

  TranscriptLine({required this.time, required this.text});

  factory TranscriptLine.fromMap(Map<String, dynamic> map) {
    return TranscriptLine(
      time: Duration(seconds: map['time']),
      text: map['text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time.inSeconds,
      'text': text,
    };
  }
}

class Lecture {
  final String id;           // e.g. 0474
  final String title;        // lecture title/topic
  final String book;         // e.g. Bhagavad-gita
  final String textNumber;   // e.g. 5-1
  final String date;         // e.g. 05-10-1972
  final String location;     // e.g. Los Angeles
  final String audioPath;    // asset path
  final List<TranscriptLine> transcript; // transcript lines (empty if none)

  Lecture({
    required this.id,
    required this.title,
    required this.book,
    required this.textNumber,
    required this.date,
    required this.location,
    required this.audioPath,
    List<TranscriptLine>? transcript,
  }) : transcript = transcript ?? [];

  factory Lecture.fromMap(Map<String, dynamic> map) {
    return Lecture(
      id: map['id'],
      title: map['title'],
      book: map['book'],
      textNumber: map['textNumber'],
      date: map['date'],
      location: map['location'],
      audioPath: map['audioPath'],
      transcript: map['transcript'] != null
          ? (map['transcript'] as List)
              .map((e) => TranscriptLine.fromMap(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'book': book,
      'textNumber': textNumber,
      'date': date,
      'location': location,
      'audioPath': audioPath,
      'transcript': transcript.map((e) => e.toMap()).toList(),
    };
  }
}  