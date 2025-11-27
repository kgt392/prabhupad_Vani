import 'package:flutter/material.dart';
import 'kirtan_detail_page.dart';
import 'obb_audio_helper.dart';
import 'data/kirtans.dart';
import 'models/kirtan.dart';

class KirtanListPage extends StatefulWidget {
  final String type; // Bhajan, Kirtan, Japa
  final String initialQuery;

  const KirtanListPage({super.key, required this.type, this.initialQuery = ''});

  @override
  State<KirtanListPage> createState() => _KirtanListPageState();
}

class _KirtanListPageState extends State<KirtanListPage> {
  String query = '';

  @override
  void initState() {
    super.initState();
    query = widget.initialQuery;
  }

  List _filtered() {
    final q = query.toLowerCase();
    return allKirtansData
        .where((k) => k.type == widget.type)
        .where((k) => q.isEmpty || k.title.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _navigateToDetail(Kirtan kirtan) async {
    try {
      print(
        '🎵 KirtanListPage: Navigating to detail - ID: ${kirtan.id}, Title: ${kirtan.title}',
      );

      final audioFileName = kirtan.audioPath.split('/').last;
      print('🎵 KirtanListPage: Looking for audio file: $audioFileName');

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final obbAudioPath = await getAudioPathFromObb(audioFileName);

        // Hide loading indicator
        Navigator.of(context).pop();

        if (obbAudioPath != null) {
          print('✅ KirtanListPage: Using OBB audio: $obbAudioPath');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  KirtanDetailPage(kirtan: kirtan, obbAudioPath: obbAudioPath),
            ),
          );
        } else {
          
          // Show error message to user

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => KirtanDetailPage(kirtan: kirtan)),
          );
        }
      } catch (e) {
        // Hide loading indicator
        Navigator.of(context).pop();

        print('❌ KirtanListPage: Error loading audio: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ KirtanListPage: Error navigating to detail: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating to detail: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered();
    return Scaffold(
      appBar: AppBar(title: Text(widget.type), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search kirtans...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          const Divider(height: 16, thickness: 0.6),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No tracks found'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final k = list[index];
                      return Card(
                        elevation: 0.5,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.purple.shade50,
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.purple,
                            ),
                          ),
                          title: Text(
                            k.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            [k.location, k.date]
                                .whereType<String>()
                                .where((e) => e.isNotEmpty)
                                .join(' • '),
                          ),
                          onTap: () => _navigateToDetail(k),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
