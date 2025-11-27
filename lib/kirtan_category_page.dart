import 'package:flutter/material.dart';
import 'data/kirtans.dart';
import 'kirtan_list_page.dart';

class KirtanCategoryPage extends StatefulWidget {
  const KirtanCategoryPage({super.key});

  @override
  State<KirtanCategoryPage> createState() => _KirtanCategoryPageState();
}

class _KirtanCategoryPageState extends State<KirtanCategoryPage> {
  String query = '';

  List<String> get _types {
    final types = allKirtansData.map((k) => k.type.trim()).where((t) => t.isNotEmpty).toSet().toList();
    types.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return types;
  }

  List<String> get _filteredTypes {
    if (query.trim().isEmpty) return _types;
    final q = query.toLowerCase();
    final names = allKirtansData.where((k) => k.title.toLowerCase().contains(q)).map((k) => k.type).toSet().toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  @override
  Widget build(BuildContext context) {
    final types = _filteredTypes;
    return Scaffold(
      appBar: AppBar(title: const Text('Kirtan Categories'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search kirtans by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          const Divider(height: 16, thickness: 0.6),
          Expanded(
            child: ListView.builder(
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                final count = allKirtansData.where((k) => k.type == type && k.title.toLowerCase().contains(query.toLowerCase())).length;
                return Card(
                  elevation: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(type, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('$count tracks'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KirtanListPage(type: type, initialQuery: query),
                        ),
                      );
                    },
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


