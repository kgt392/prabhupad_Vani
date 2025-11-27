import 'dart:async';
import 'audio_manager.dart';
import 'package:flutter/material.dart';
import 'lecture_list_page.dart';
import 'lecture_detail_page.dart';
// ignore: unused_import
import 'models/lecture.dart';
import 'data/all_lectures.dart'; // ✅ contains allLecturesData
import 'obb_audio_helper.dart';

class CategoryPage extends StatefulWidget {
  final String type;

  const CategoryPage({super.key, required this.type});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String searchQuery = "";
  String? selectedYear;
  String? selectedLocation;
  String? selectedBook;
  Timer? _debounce;
  List<Lecture>? _cachedResults;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  List<Lecture>? _cachedFilteredLectures;

  // Normalize strings for diacritic-insensitive comparisons.
  // This is a small, local replacement map for common Latin diacritics.
  String _stripDiacritics(String input) {
    if (input.isEmpty) return input;
    var s = input;
    const replacements = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a',
      'ç': 'c', 'ć': 'c', 'č': 'c',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ė': 'e', 'ę': 'e',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i',
      'ñ': 'n', 'ń': 'n',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ō': 'o',
      'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u',
      'ý': 'y', 'ÿ': 'y',
      'š': 's', 'ś': 's',
      'ž': 'z', 'ź': 'z', 'ż': 'z',
      'ř': 'r', 'ť': 't', 'ď': 'd',
      // Uppercase
      'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A', 'Å': 'A', 'Ā': 'A',
      'Ç': 'C', 'Ć': 'C', 'Č': 'C',
      'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E', 'Ē': 'E', 'Ę': 'E',
      'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I', 'Ī': 'I',
      'Ñ': 'N', 'Ń': 'N',
      'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O', 'Ø': 'O', 'Ō': 'O',
      'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U', 'Ū': 'U',
      'Ý': 'Y', 'Ÿ': 'Y',
      'Š': 'S', 'Ś': 'S',
      'Ž': 'Z', 'Ź': 'Z', 'Ż': 'Z',
      'Ř': 'R', 'Ť': 'T', 'Ď': 'D',
    };

    replacements.forEach((k, v) {
      s = s.replaceAll(k, v);
    });
    return s;
  }

  String _normalize(String input) =>
      _stripDiacritics(input).toLowerCase().trim();

  // Pre-compute dropdown data from all lectures
  late final List<String> _allYears = (() {
    // Only show 4-digit years (XXXX format), exclude 2-digit years or null values
    final yearPattern = RegExp(r'(19|20)\d{2}');
    final yearsSet = <String>{};
    for (final e in allLecturesData) {
      final match = yearPattern.firstMatch(e.date.trim());
      if (match != null && match.group(0)!.length == 4) {
        yearsSet.add(match.group(0)!);
      }
    }
    final years = yearsSet.toList();
    years.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    print('Available years: $years'); // Debug print
    return years;
  })();

  late final List<String> _allLocations = (() {
    // Only show complete location names, exclude short codes like NY, VN, etc.
    final shortCodes = {
      "vn",
      "la",
      "sf",
      "lon",
      "bom",
      "chi",
      "pit",
      "del",
      "det",
      "syd",
      "hyd",
      "tor",
      "ar",
      "mel",
      "sea",
      "fij",
      "tir",
      "par",
      "gai",
      "mau",
      "auc",
      "dal",
      "jpn",
      "ger",
      "rom",
      "mex",
      "jai",
      "kor",
      "bos",
      "nv",
      "bud",
      "mon",
      "hw",
      "cal",
      "bhu",
      "atl",
      "may",
      "gen",
      "hon",
      "ahm",
      "ed",
      "fr",
      "us",
      "uk",
      "ca",
      "au",
    };
    final unwanted = {"pc", "bs", "de", "me"};

    final cleaned = allLecturesData
        .map((e) => e.location.trim())
        .where((loc) {
          final l = loc.toLowerCase();
          if (l.isEmpty) return false;
          if (RegExp(r'^\d+$').hasMatch(l)) return false;
          if (l.length < 4)
            return false; // Require at least 4 characters for complete names
          if (unwanted.contains(l)) return false;
          if (shortCodes.contains(l)) return false; // Exclude short codes
          return true;
        })
        .toSet()
        .toList();
    cleaned.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return cleaned;
  })();

  late final List<String> _allBooks = (() {
    // Only show specific books you want in the filter
    final allowedBooks = {
      "Bhagavad-gita",
      "Brahma Samhita",
      "Caitanya-caritamrta",
      "Isopanishad",
      "Nectar of Devotion",
      "Krishna Book",
      "Morning Walks",
      "Interviews",
      "Initiations",
      "Festival",
      "Story",
      "Discussion",
      "Devotee Address",
    };

    final books = allLecturesData
        .map((e) => e.book.trim())
        .where((b) => b.isNotEmpty && allowedBooks.contains(b))
        .toSet()
        .toList();
    books.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return books;
  })();

  List<Lecture> get _filteredLectures {
    // Return cached results if available
    if (_cachedResults != null) {
      return _cachedResults!;
    }

    // Start with a filtered list for the search query
    List<Lecture> filtered;
    final query = searchQuery.trim();

    if (query.isEmpty) {
      filtered = List.from(allLecturesData);
    } else {
      // Split search query into words for better matching
      final searchTerms = query
          .toLowerCase()
          .split(' ')
          .where((term) => term.isNotEmpty)
          .toList();

      filtered = allLecturesData.where((lecture) {
        // A lecture matches if all search terms are found in any of its fields
        return searchTerms.every((term) {
          final title = lecture.title.toLowerCase();
          final book = lecture.book.toLowerCase();
          final location = lecture.location.toLowerCase();
          final date = lecture.date.toLowerCase();

          return title.contains(term) ||
              book.contains(term) ||
              location.contains(term) ||
              date.contains(term);
        });
      }).toList();
    }

    // Apply filters sequentially to reduce iterations
    if (selectedYear != null) {
      filtered = filtered.where((l) => l.date.contains(selectedYear!)).toList();
    }

    if (selectedLocation != null) {
      filtered = filtered.where((l) => l.location == selectedLocation).toList();
    }

    if (selectedBook != null) {
      filtered = filtered.where((l) => l.book == selectedBook).toList();
    }

    // Cache the results
    _cachedResults = filtered;

    print('Filtered lectures count: ${filtered.length}'); // Debug print
    print('Selected year: $selectedYear'); // Debug print
    return filtered;
  }

  List<String> get _filteredBooks {
    final books = _filteredLectures
        .map((e) => e.book.trim())
        .where((b) => b.isNotEmpty)
        .toList();
    final counts = <String, int>{};
    for (final b in books) {
      counts[b] = (counts[b] ?? 0) + 1;
    }
    final unique = counts.keys.toList();
    unique.sort((a, b) {
      final byCount = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
      if (byCount != 0) return byCount;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return unique;
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        hint: Text(hint, style: const TextStyle(color: Colors.black87)),
        value: value,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
        isDense: true,
        selectedItemBuilder: (context) => [
          for (final _ in ["All", ...items])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(value ?? hint, style: const TextStyle(fontSize: 14)),
            ),
        ],
        items: ["All", ...items]
            .map(
              (item) => DropdownMenuItem(
                value: item == "All" ? null : item,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = _filteredBooks;
    final isFiltered =
        searchQuery.trim().isNotEmpty ||
        selectedYear != null ||
        selectedLocation != null ||
        selectedBook != null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.type), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search lectures by topic...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {
                    searchQuery = value;
                    _cachedResults = null; // Clear cache for new search
                  });
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildFilterDropdown(
                      hint: "Year",
                      value: selectedYear,
                      items: _allYears,
                      onChanged: (val) {
                        setState(() {
                          selectedYear = val;
                          _cachedResults =
                              null; // Clear cache when filter changes
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildFilterDropdown(
                      hint: "Location",
                      value: selectedLocation,
                      items: _allLocations,
                      onChanged: (val) {
                        setState(() {
                          selectedLocation = val;
                          _cachedResults =
                              null; // Clear cache when filter changes
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Make the Book dropdown wider so long book names don't wrap.
                        // Use a responsive width: prefer 60% of screen but at least 200
                        // and not larger than the available constraints.
                        final screenWidth = MediaQuery.of(context).size.width;
                        final preferred = screenWidth * 0.3;
                        final width = preferred.clamp(
                          180.0,
                          constraints.maxWidth,
                        );
                        return SizedBox(
                          width: width,
                          child: _buildFilterDropdown(
                            hint: "Book",
                            value: selectedBook,
                            items: _allBooks,
                            onChanged: (val) {
                              setState(() {
                                selectedBook = val;
                                _cachedResults =
                                    null; // Clear cache when filter changes
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  if (selectedYear != null ||
                      selectedLocation != null ||
                      selectedBook != null) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedYear = null;
                          selectedLocation = null;
                          selectedBook = null;
                          _cachedResults =
                              null; // Clear cache when filters are reset
                        });
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text("Clear"),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Divider(height: 16, thickness: 0.6),

          Expanded(
            child: isFiltered
                ? (_filteredLectures.isEmpty
                      ? const Center(child: Text("No lectures found"))
                      : ListView.builder(
                          itemCount: _filteredLectures.length,
                          itemBuilder: (context, index) {
                            final lec = _filteredLectures[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 6.0,
                              ),
                              child: Card(
                                elevation: 0.5,
                                shadowColor: Colors.black12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.orange.shade50,
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  title: Text(
                                    "${lec.textNumber.isNotEmpty ? lec.textNumber + " • " : ""}${lec.title}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${lec.date} • ${lec.location}",
                                    style: const TextStyle(color: Colors.grey),
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
                                      final obbAudioPath =
                                          await getAudioPathFromObb(
                                            audioFileName,
                                          );

                                      Navigator.of(
                                        context,
                                      ).pop(); // Hide loading

                                      if (obbAudioPath != null) {
                                        print(
                                          '✅ Using OBB audio: $obbAudioPath',
                                        );
                                        // Preload the OBB file so player is ready
                                        await AudioManager.instance
                                            .preloadLectureWithMeta(
                                              lectureId: lec.id,
                                              audioPath: lec.audioPath,
                                              filePath: obbAudioPath,
                                              title: lec.title,
                                              subtitle: lec.book,
                                            );
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
                                        print(
                                          '⚠️ Audio not found in OBB, using asset fallback',
                                        );

                                        // Preload asset
                                        await AudioManager.instance
                                            .preloadLectureWithMeta(
                                              lectureId: lec.id,
                                              audioPath: lec.audioPath,
                                              title: lec.title,
                                              subtitle: lec.book,
                                            );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                LectureDetailPage(lecture: lec),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      Navigator.of(
                                        context,
                                      ).pop(); // Hide loading
                                      print('❌ Error loading audio: $e');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error loading audio: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ))
                : (books.isEmpty
                      ? const Center(child: Text("No books found"))
                      : ListView.builder(
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            final count = _filteredLectures
                                .where((e) => e.book.trim() == book)
                                .length;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 6.0,
                              ),
                              child: Card(
                                elevation: 0.5,
                                shadowColor: Colors.black12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  // Removed book icon for a cleaner look
                                  title: Text(
                                    book,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text("$count lectures"),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LectureListPage(
                                          category: book,
                                          type: book,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        )),
          ),
        ],
      ),
    );
  }
}
