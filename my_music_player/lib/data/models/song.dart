import 'package:isar/isar.dart';

part 'song.g.dart';

/// 歌曲模型 - 存储音频文件的元数据信息
@collection
class Song {
  /// 自增主键
  Id id = Isar.autoIncrement;

  /// 文件完整路径（唯一索引）
  @Index(unique: true)
  late String filePath;

  /// 歌曲标题
  @Index()
  late String title;

  /// 艺术家/歌手
  @Index()
  late String artist;

  /// 专辑名称
  @Index()
  late String album;

  /// 专辑艺术家（可能与歌手不同）
  String? albumArtist;

  /// 发行年份
  int? year;

  /// 时长（毫秒）
  int? durationMs;

  /// 比特率（kbps）
  int? bitrate;

  /// 采样率（Hz）
  int? sampleRate;

  /// 文件大小（字节）
  int? fileSize;

  /// 文件最后修改时间（用于增量扫描）
  @Index()
  late DateTime modifiedTime;

  /// 封面图片（二进制数据，可能为空）
  List<byte>? coverBytes;

  /// 音轨编号
  int? trackNumber;

  /// 碟片编号
  int? discNumber;

  /// 创建时间
  late DateTime createdAt;

  /// 更新时间
  late DateTime updatedAt;

  /// 构造函数
  Song() {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// 从元数据创建 Song 对象
  static Song fromMetadata({
    required String filePath,
    required String title,
    required String artist,
    required String album,
    String? albumArtist,
    int? year,
    int? durationMs,
    int? bitrate,
    int? sampleRate,
    int? fileSize,
    required DateTime modifiedTime,
    List<int>? coverBytes,
    int? trackNumber,
    int? discNumber,
  }) {
    final song = Song()
      ..filePath = filePath
      ..title = title
      ..artist = artist
      ..album = album
      ..albumArtist = albumArtist
      ..year = year
      ..durationMs = durationMs
      ..bitrate = bitrate
      ..sampleRate = sampleRate
      ..fileSize = fileSize
      ..modifiedTime = modifiedTime
      ..coverBytes = coverBytes
      ..trackNumber = trackNumber
      ..discNumber = discNumber;
    return song;
  }

  /// 格式化时长显示（mm:ss）
  String get formattedDuration {
    if (durationMs == null) return '--:--';
    final duration = Duration(milliseconds: durationMs!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
