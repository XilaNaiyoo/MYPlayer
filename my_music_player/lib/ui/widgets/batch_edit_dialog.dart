import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../data/models/song.dart';
import '../../data/services/metadata_service.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';

/// 批量编辑元数据对话框
class BatchEditDialog extends ConsumerStatefulWidget {
  /// 要编辑的歌曲列表
  final List<Song> songs;

  const BatchEditDialog({super.key, required this.songs});

  @override
  ConsumerState<BatchEditDialog> createState() => _BatchEditDialogState();
}

class _BatchEditDialogState extends ConsumerState<BatchEditDialog> {
  // 编辑字段控制器
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _yearController = TextEditingController();

  // 是否修改对应字段的开关
  bool _editTitle = false;
  bool _editArtist = false;
  bool _editAlbum = false;
  bool _editYear = false;
  bool _editCover = false;

  // 新封面图片数据
  Uint8List? _newCoverBytes;

  // 是否正在保存
  bool _isSaving = false;

  // 保存进度
  int _savedCount = 0;

  // 原始值（合并后的字符串，不同值用;连接）
  String _originalTitle = '';
  String _originalArtist = '';
  String _originalAlbum = '';
  String _originalYear = '';

  @override
  void initState() {
    super.initState();
    _computeOriginalValues();
  }

  /// 计算原始值（合并多个歌曲的值，不同值用;连接）
  void _computeOriginalValues() {
    final titles = widget.songs.map((s) => s.title).toSet();
    final artists = widget.songs.map((s) => s.artist).toSet();
    final albums = widget.songs.map((s) => s.album).toSet();
    final years = widget.songs
        .map((s) => s.year?.toString() ?? '')
        .where((y) => y.isNotEmpty)
        .toSet();

    _originalTitle = titles.length == 1 ? titles.first : titles.join('; ');
    _originalArtist = artists.length == 1 ? artists.first : artists.join('; ');
    _originalAlbum = albums.length == 1 ? albums.first : albums.join('; ');
    _originalYear = years.length == 1 ? years.first : years.join('; ');

    // 设置初始值到文本框
    _titleController.text = _originalTitle;
    _artistController.text = _originalArtist;
    _albumController.text = _originalAlbum;
    _yearController.text = _originalYear;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      child: Container(
        width: 550,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '批量编辑 ${widget.songs.length} 首歌曲',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '勾选要修改的字段，修改内容后保存',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 编辑字段列表
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildEditField(
                      label: '标题',
                      controller: _titleController,
                      enabled: _editTitle,
                      onToggle: (v) => setState(() => _editTitle = v),
                      originalValue: _originalTitle,
                    ),
                    _buildEditField(
                      label: '艺术家',
                      controller: _artistController,
                      enabled: _editArtist,
                      onToggle: (v) => setState(() => _editArtist = v),
                      originalValue: _originalArtist,
                    ),
                    _buildEditField(
                      label: '专辑',
                      controller: _albumController,
                      enabled: _editAlbum,
                      onToggle: (v) => setState(() => _editAlbum = v),
                      originalValue: _originalAlbum,
                    ),
                    _buildEditField(
                      label: '年份',
                      controller: _yearController,
                      enabled: _editYear,
                      onToggle: (v) => setState(() => _editYear = v),
                      originalValue: _originalYear,
                      keyboardType: TextInputType.number,
                    ),
                    _buildCoverField(),
                  ],
                ),
              ),
            ),

            // 保存进度
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: widget.songs.isNotEmpty
                          ? _savedCount / widget.songs.length
                          : 0,
                      backgroundColor: AppTheme.dividerColor,
                      valueColor: const AlwaysStoppedAnimation(
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '正在保存 $_savedCount/${widget.songs.length}...',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

            // 底部按钮
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving || !_hasChanges ? null : _saveChanges,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('保存修改'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 是否有要修改的字段
  bool get _hasChanges =>
      _editTitle || _editArtist || _editAlbum || _editYear || _editCover;

  /// 构建编辑字段
  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required String originalValue,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // 判断是否为多值（不同歌曲有不同值）
    final isMultiValue = originalValue.contains('; ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled ? AppTheme.backgroundColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled
              ? AppTheme.primaryColor.withValues(alpha: 0.3)
              : AppTheme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签行
          Row(
            children: [
              Checkbox(
                value: enabled,
                onChanged: _isSaving ? null : (v) => onToggle(v ?? false),
                activeColor: AppTheme.primaryColor,
              ),
              Text(
                label,
                style: TextStyle(
                  color: enabled
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: enabled ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              if (isMultiValue && !enabled) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '多值',
                    style: TextStyle(color: Colors.orange, fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
          // 当前值显示（未启用时）
          if (!enabled)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Text(
                originalValue.isEmpty ? '(无)' : originalValue,
                style: TextStyle(
                  color: AppTheme.textDisabled,
                  fontSize: 13,
                  fontStyle: originalValue.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // 输入框（启用时）
          if (enabled)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 8),
              child: TextField(
                controller: controller,
                enabled: !_isSaving,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: '输入新的$label',
                  hintStyle: const TextStyle(color: AppTheme.textDisabled),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建封面编辑字段
  Widget _buildCoverField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _editCover ? AppTheme.backgroundColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _editCover
              ? AppTheme.primaryColor.withValues(alpha: 0.3)
              : AppTheme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签行
          Row(
            children: [
              Checkbox(
                value: _editCover,
                onChanged: _isSaving
                    ? null
                    : (v) => setState(() {
                        _editCover = v ?? false;
                        if (!_editCover) _newCoverBytes = null;
                      }),
                activeColor: AppTheme.primaryColor,
              ),
              Text(
                '封面',
                style: TextStyle(
                  color: _editCover
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: _editCover ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
          // 封面选择（启用时）
          if (_editCover)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 8),
              child: Row(
                children: [
                  // 封面预览
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: _newCoverBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              _newCoverBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            color: AppTheme.textDisabled,
                            size: 32,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // 选择按钮
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isSaving ? null : _pickCoverImage,
                        icon: const Icon(Icons.folder_open, size: 18),
                        label: const Text('选择图片'),
                      ),
                      if (_newCoverBytes != null) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isSaving
                              ? null
                              : () {
                                  setState(() => _newCoverBytes = null);
                                },
                          child: const Text(
                            '清除',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 选择封面图片
  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      setState(() {
        _newCoverBytes = bytes;
      });
    }
  }

  /// 保存修改
  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
      _savedCount = 0;
    });

    final metadataService = MetadataService();
    final failedPaths = <String>[];

    // 构建要修改的元数据
    final metadata = AudioMetadata(
      title: _editTitle && _titleController.text.isNotEmpty
          ? _titleController.text
          : null,
      artist: _editArtist && _artistController.text.isNotEmpty
          ? _artistController.text
          : null,
      album: _editAlbum && _albumController.text.isNotEmpty
          ? _albumController.text
          : null,
      year: _editYear && _yearController.text.isNotEmpty
          ? int.tryParse(_yearController.text)
          : null,
      coverBytes: _editCover && _newCoverBytes != null
          ? _newCoverBytes!.toList()
          : null,
    );

    // 逐个写入文件
    for (final song in widget.songs) {
      try {
        final success = await metadataService.writeMetadata(
          song.filePath,
          metadata,
        );
        if (!success) {
          failedPaths.add(song.filePath);
        }
      } catch (e) {
        failedPaths.add(song.filePath);
        print('写入元数据失败: ${song.filePath}, 错误: $e');
      }

      setState(() {
        _savedCount++;
      });
    }

    // 刷新数据库
    ref.read(libraryRefreshProvider.notifier).refresh();

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      Navigator.pop(context, true); // 返回 true 表示有修改

      // 显示结果
      if (failedPaths.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功修改 ${widget.songs.length} 首歌曲的元数据'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.songs.length - failedPaths.length} 首成功, ${failedPaths.length} 首失败',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
