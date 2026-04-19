import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';

class LogEditorPage extends StatefulWidget {
  final LogController controller;
  final LogModel? existingLog;
  final int? index;

  const LogEditorPage({
    super.key,
    required this.controller,
    this.existingLog,
    this.index,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  static const String _defaultCategory = 'Pribadi';

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _selectedCategory;
  late bool _isPublic;
  bool _isSaving = false;

  bool get _isEdit => widget.existingLog != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingLog?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.existingLog?.description ?? '',
    );
    _selectedCategory = widget.existingLog?.category ?? _defaultCategory;
    _isPublic = widget.existingLog?.isPublic ?? false;
    _descController.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _saveLog() async {
    final messenger = ScaffoldMessenger.of(context);
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Judul dan deskripsi tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEdit) {
        await widget.controller.updateLog(
          widget.existingLog!,
          title,
          description,
          _selectedCategory,
          _isPublic,
        );
      } else {
        await widget.controller.addLog(
          title,
          description,
          _selectedCategory,
          _isPublic,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _descController.removeListener(_onDescriptionChanged);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit Aktivitas' : 'Tambah Aktivitas'),
          actions: [
            IconButton(
              onPressed: _isSaving ? null : _saveLog,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Editor'),
              Tab(text: 'Pratinjau'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (Markdown)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      'Panduan Markdown:\n**Tebal** |  *Miring* |  # Heading 1  |  ## Heading 2  |  - List',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Publikasikan ke Tim'),
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Markdown(
                data: _descController.text.replaceAll('\n', '  \n'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
