// import 'package:flutter/material.dart';
// import 'lecture_detail_page.dart';
// // ignore: unused_import
// import 'models/lecture.dart';
// import 'data/lectures.dart';

// class LectureListPage extends StatelessWidget {
//   final String category;
//   final String type;

//   const LectureListPage({super.key, required this.category, required this.type});

//   @override
//   Widget build(BuildContext context) {
//     final filteredLectures = allLectures.where(
//       (lec) => lec.book.toLowerCase() == category.toLowerCase(),
//     ).toList();

//     return Scaffold(
//       appBar: AppBar(title: Text("$category - $type")),
//       body: ListView.builder(
//         itemCount: filteredLectures.length,
//         itemBuilder: (context, index) {
//           final lecture = filteredLectures[index];
//           return ListTile(
//             title: Text(lecture.title),
//             subtitle: Text("${lecture.date} • ${lecture.location}"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => LectureDetailPage(lecture: lecture),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'lecture_detail_page.dart';
// import 'models/lecture.dart';

// class LectureListPage extends StatelessWidget {
//   final List<Lecture> lectures;
//   final String? category; // optional, e.g., Bhagavad-gita

//   const LectureListPage({super.key, required this.lectures, this.category});

//   List<Lecture> _sortLectures(List<Lecture> list) {
//     int parsePart(String part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

//     int compareTextNumber(String a, String b) {
//       final partsA = a.split(RegExp(r'[.-]')).map(parsePart).toList();
//       final partsB = b.split(RegExp(r'[.-]')).map(parsePart).toList();

//       for (int i = 0; i < partsA.length && i < partsB.length; i++) {
//         if (partsA[i] != partsB[i]) return partsA[i].compareTo(partsB[i]);
//       }
//       return partsA.length.compareTo(partsB.length);
//     }

//     final sorted = List<Lecture>.from(list);
//     sorted.sort((a, b) {
//       // First sort by textNumber if exists
//       if (a.textNumber.isNotEmpty && b.textNumber.isNotEmpty) {
//         return compareTextNumber(a.textNumber, b.textNumber);
//       } else if (a.textNumber.isNotEmpty) {
//         return -1;
//       } else if (b.textNumber.isNotEmpty) {
//         return 1;
//       } else {
//         // fallback: by title
//         return a.title.compareTo(b.title);
//       }
//     });

//     return sorted;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sortedLectures = _sortLectures(lectures);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(category ?? "Lectures"),
//         centerTitle: true,
//       ),
//       body: ListView.separated(
//         itemCount: sortedLectures.length,
//         separatorBuilder: (_, __) => const Divider(
//           height: 1,
//           thickness: 0.5,
//           color: Color(0xFFE0E0E0),
//           indent: 16,
//           endIndent: 16,
//         ),
//         itemBuilder: (context, index) {
//           final lec = sortedLectures[index];
//           return ListTile(
//             title: Text(
//               "${lec.textNumber.isNotEmpty ? lec.textNumber + " • " : ""}${lec.title}",
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//             ),
//             subtitle: Text(
//               "${lec.date} • ${lec.location}",
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             trailing: const Icon(
//               Icons.play_arrow,
//               color: Colors.deepOrange,
//             ),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => LectureDetailPage(lecture: lec),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'lecture_detail_page.dart';
import 'models/lecture.dart';
import 'data/all_lectures.dart';
import 'obb_audio_helper.dart';

class LectureListPage extends StatelessWidget {
  final String category; // e.g., "Book"
  final String type; // e.g., "BG"

  const LectureListPage({
    super.key,
    required this.category,
    required this.type,
  });

  // Sorting by textNumber or title
  List<Lecture> _sortLectures(List<Lecture> list) {
    int parsePart(String part) =>
        int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    int compareTextNumber(String a, String b) {
      final partsA = a.split(RegExp(r'[.-]')).map(parsePart).toList();
      final partsB = b.split(RegExp(r'[.-]')).map(parsePart).toList();

      for (int i = 0; i < partsA.length && i < partsB.length; i++) {
        if (partsA[i] != partsB[i]) return partsA[i].compareTo(partsB[i]);
      }
      return partsA.length.compareTo(partsB.length);
    }

    final sorted = List<Lecture>.from(list);
    sorted.sort((a, b) {
      if (a.textNumber.isNotEmpty && b.textNumber.isNotEmpty) {
        return compareTextNumber(a.textNumber, b.textNumber);
      } else if (a.textNumber.isNotEmpty) {
        return -1;
      } else if (b.textNumber.isNotEmpty) {
        return 1;
      } else {
        return a.title.compareTo(b.title);
      }
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final filteredLectures = allLecturesData
        .where((lec) => lec.book == type)
        .toList();

    final sortedLectures = _sortLectures(filteredLectures);

    return Scaffold(
      appBar: AppBar(title: Text(type), centerTitle: true),
      body: sortedLectures.isEmpty
          ? const Center(
              child: Text(
                "No lectures available",
                style: TextStyle(fontSize: 16),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _Header(type: type, count: sortedLectures.length),
                  ),
                ),
                SliverList.builder(
                  itemCount: sortedLectures.length,
                  itemBuilder: (context, index) {
                    final lec = sortedLectures[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 6.0,
                      ),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade50,
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.deepOrange,
                            ),
                          ),
                          title: Text(
                            "${lec.textNumber.isNotEmpty ? lec.textNumber + " • " : ""}${lec.title}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "${lec.date} • ${lec.location}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () async {
                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              final audioFileName = lec.audioPath
                                  .split('/')
                                  .last;
                              final obbAudioPath = await getAudioPathFromObb(
                                audioFileName,
                              );
                              Navigator.of(context).pop(); // Hide loading
                              if (obbAudioPath != null) {
                                print('✅ Using  audio: $obbAudioPath');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LectureDetailPage(
                                      lecture: lec,
                                      obbAudioPath: obbAudioPath,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LectureDetailPage(lecture: lec),
                                  ),
                                );
                              }
                            } catch (e) {
                              Navigator.of(context).pop(); // Hide loading
                              print('❌ Error loading audio: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error loading audio: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final String type;
  final int count;

  const _Header({required this.type, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$count lectures",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
