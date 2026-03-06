import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:intl/intl.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  static const List<String> _categories = ['Pekerjaan', 'Pribadi', 'Urgent'];

  // Key untuk trigger rebuild FutureBuilder (auto-refresh)
  Key _futureKey = UniqueKey();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _controller = LogController();
  }

  // Trigger refresh dengan membuat key baru
  void _refreshData() {
    setState(() {
      _futureKey = UniqueKey();
    });
  }

  Future<List<LogModel>> _fetchLogs() async {
    try {
      // Coba load dari cloud dengan timeout
      await _controller.loadFromCloud();

      // Berhasil terhubung ke cloud
      if (mounted) {
        setState(() => _isOffline = false);
      }

      // Auto-sync data yang dibuat offline (jika ada)
      final syncedCount = await _controller.syncToCloud();
      if (syncedCount > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ $syncedCount data offline berhasil di-sync ke cloud',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Return data dari controller
      final logs = List<LogModel>.from(_controller.logs.value);
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return logs;
    } catch (e, stackTrace) {
      LogHelper.warning(
        'log_view.dart',
        'Cloud tidak tersedia, menggunakan data lokal',
      );

      // Fallback ke local storage
      await _controller.loadFromDisk();

      if (mounted) {
        setState(() => _isOffline = true);
      }

      final logs = List<LogModel>.from(_controller.logs.value);
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return logs;
    }
  }

  Future<void> _showInputDialog({LogModel? existingLog, int? index}) async {
    final titleController = TextEditingController(
      text: existingLog?.title ?? '',
    );
    final descController = TextEditingController(
      text: existingLog?.description ?? '',
    );
    final selectedCategory = ValueNotifier<String>(
      existingLog?.category ?? _categories[1],
    );
    final isEdit = existingLog != null && index != null;

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
                    value: category,
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
              onPressed: () async {
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

                try {
                  if (isEdit) {
                    // Update existing log
                    await _controller.updateLog(index, title, desc, category);

                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isOffline
                                ? 'Aktivitas diperbarui (akan di-sync otomatis saat online)'
                                : 'Aktivitas berhasil diperbarui',
                          ),
                        ),
                      );
                    }
                  } else {
                    // Add new log
                    await _controller.addLog(title, desc, category);

                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isOffline
                                ? 'Aktivitas ditambahkan (akan di-sync otomatis saat online)'
                                : 'Aktivitas berhasil ditambahkan',
                          ),
                        ),
                      );
                    }
                  }

                  // Auto-refresh UI
                  _refreshData();

                  if (mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menyimpan: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
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

  Future<void> _confirmDelete(LogModel log, int index) async {
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
              onPressed: () async {
                try {
                  await _controller.removeLog(index);

                  // Auto-refresh UI
                  _refreshData();

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isOffline
                              ? 'Aktivitas dihapus (akan di-sync saat online)'
                              : 'Aktivitas berhasil dihapus',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
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
            Text('Data Kosong', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Belum ada catatan di MongoDB Atlas.\nTekan tombol + untuk menambahkan aktivitas pertama.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode Offline - Data akan di-sync otomatis saat online',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Format timestamp dengan intl - Homework requirement
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      // Format: "25 Jan 2026, 14:30"
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Aktivitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh dari Cloud',
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner offline yang subtle, hanya muncul saat offline
          _buildOfflineBanner(),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: ValueListenableBuilder<String>(
              valueListenable: _searchQuery,
              builder: (context, query, _) {
                return TextField(
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
                );
              },
            ),
          ),

          // FutureBuilder dengan loading state - Task 3 requirement
          Expanded(
            child: FutureBuilder<List<LogModel>>(
              key: _futureKey, // Untuk auto-refresh
              future: _fetchLogs(),
              builder: (context, snapshot) {
                // Loading State dengan CircularProgressIndicator
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat data...'),
                      ],
                    ),
                  );
                }

                // Error State - jarang terjadi karena ada fallback
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 64,
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi Kesalahan',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final logs = snapshot.data ?? [];

                // Empty State - "Data Kosong" - Task 3 requirement
                if (logs.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => _refreshData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 250,
                        child: _buildEmptyState(),
                      ),
                    ),
                  );
                }

                // Filter by search query
                return ValueListenableBuilder<String>(
                  valueListenable: _searchQuery,
                  builder: (context, query, _) {
                    final normalizedQuery = query.trim().toLowerCase();
                    final filteredLogs = normalizedQuery.isEmpty
                        ? logs
                        : logs
                              .where(
                                (log) =>
                                    log.title.toLowerCase().contains(
                                      normalizedQuery,
                                    ) ||
                                    log.description.toLowerCase().contains(
                                      normalizedQuery,
                                    ),
                              )
                              .toList();

                    if (filteredLogs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada catatan yang cocok dengan pencarian.',
                        ),
                      );
                    }

                    // Pull-to-Refresh - Homework requirement
                    return RefreshIndicator(
                      onRefresh: () async {
                        _refreshData();
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          // Cari index asli di list lengkap
                          final originalIndex = logs.indexOf(log);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  log.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(log.description),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatTimestamp(log.timestamp),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(
                                              log.category,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            log.category,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _showInputDialog(
                                        existingLog: log,
                                        index: originalIndex >= 0
                                            ? originalIndex
                                            : index,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _confirmDelete(
                                        log,
                                        originalIndex >= 0
                                            ? originalIndex
                                            : index,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInputDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Colors.blue;
      case 'Urgent':
        return Colors.red;
      case 'Pribadi':
      default:
        return Colors.green;
    }
  }
}
