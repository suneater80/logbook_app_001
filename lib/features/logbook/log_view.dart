import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/logbook/widgets/log_item_widget.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  static const List<String> _categories = ['Pekerjaan', 'Pribadi', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _controller = LogController();
  }

  Future<void> _showInputDialog({int? index, LogModel? existingLog}) async {
    final titleController = TextEditingController(
      text: existingLog?.title ?? '',
    );
    final descController = TextEditingController(
      text: existingLog?.description ?? '',
    );
    final selectedCategory = ValueNotifier<String>(
      existingLog?.category ?? _categories[1],
    );
    final isEdit = index != null && existingLog != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Aktivitas' : 'Tambah Aktivitas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String>(
                valueListenable: selectedCategory,
                builder: (context, category, _) {
                  return DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory.value = value;
                      }
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                final category = selectedCategory.value;

                if (title.isEmpty || desc.isEmpty) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul dan deskripsi wajib diisi'),
                    ),
                  );
                  return;
                }

                if (isEdit) {
                  _controller.updateLog(index, title, desc, category);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Aktivitas berhasil diperbarui'),
                    ),
                  );
                } else {
                  _controller.addLog(title, desc, category);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Aktivitas berhasil ditambahkan'),
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    descController.dispose();
    selectedCategory.dispose();
  }

  Future<void> _confirmDelete(int index) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Aktivitas'),
          content: const Text('Yakin ingin menghapus aktivitas ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.removeLog(index);
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Aktivitas berhasil dihapus')),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/foto.jpg',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada catatan nih',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Tekan tombol + untuk menambahkan aktivitas pertama kamu.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Aktivitas')),
      body: ValueListenableBuilder<String>(
        valueListenable: _searchQuery,
        builder: (context, query, _) {
          return ValueListenableBuilder<List<LogModel>>(
            valueListenable: _controller.logs,
            builder: (context, logs, child) {
              final normalizedQuery = query.trim().toLowerCase();
              final filteredLogs = normalizedQuery.isEmpty
                  ? logs
                  : logs
                        .where(
                          (log) =>
                              log.title.toLowerCase().contains(normalizedQuery),
                        )
                        .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: TextField(
                      onChanged: (value) => _searchQuery.value = value,
                      decoration: InputDecoration(
                        hintText: 'Cari berdasarkan judul...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _searchQuery.value = '',
                              ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: logs.isEmpty
                        ? _buildEmptyState()
                        : filteredLogs.isEmpty
                        ? const Center(
                            child: Text(
                              'Catatan dengan judul tersebut tidak ditemukan.',
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                            itemCount: filteredLogs.length,
                            itemBuilder: (context, index) {
                              final log = filteredLogs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: LogItemWidget(
                                  log: log,
                                  onEdit: () {
                                    final originalIndex = logs.indexOf(log);
                                    if (originalIndex >= 0) {
                                      _showInputDialog(
                                        index: originalIndex,
                                        existingLog: log,
                                      );
                                    }
                                  },
                                  onDelete: () {
                                    final originalIndex = logs.indexOf(log);
                                    if (originalIndex >= 0) {
                                      _confirmDelete(originalIndex);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInputDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
