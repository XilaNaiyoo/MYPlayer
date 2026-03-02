# MYMP 架构与接口参考文档 (截至 Phase 2 中期)
> **目的**：完整记录截至 Phase 2 中期的四层架构设计、所有已实现接口与组件现状，为后续开发提供统一参考。  
> **最后更新**：2026-02-10

---

## 0. 架构总览

```
┌──────────────────────────────────────────────────────────────────────┐
│                        表现层 (Presentation)                         │
│  MainLayout / TopControlBar / Sidebar / BottomPlayerBar / QueuePanel│
│  AlbumView / ArtistView / PlaylistView / FolderView / *DetailViews  │
│  BatchEditDialog / PlaylistSelectorDialog                           │
├──────────────────────────────────────────────────────────────────────┤
│                         状态层 (State/Providers)                     │
│  PlayerProvider / QueueProvider / LibraryProvider / PlaylistProvider │
│  NavigationProvider / ScanProvider / SearchProvider / CoreProviders  │
├──────────────────────────────────────────────────────────────────────┤
│                         服务层 (Services)                            │
│  PlayerService / LibraryScanService / MetadataService                │
│  PlaylistIOService                                                  │
├──────────────────────────────────────────────────────────────────────┤
│                      基础设施层 (Infrastructure)                      │
│  DatabaseService(Isar) / media_kit / audiotags                      │
│  window_manager / file_picker / path_provider                       │
└──────────────────────────────────────────────────────────────────────┘
```

**依赖规则**：上层 → 下层单向依赖，禁止反向。

**技术栈摘要**：

| 类别 | 依赖包 | 用途 |
|:---|:---|:---|
| 状态管理 | `flutter_riverpod` | MVVM 状态绑定 |
| 数据库 | `isar` + `isar_flutter_libs` | 嵌入式 NoSQL 存储 |
| 播放引擎 | `media_kit` + `media_kit_libs_windows_audio` | 基于 mpv 的音频播放 |
| 元数据 | `audiotags` | 音频标签读写 (基于 TagLib) |
| 窗口管理 | `window_manager` | 自定义窗口、隐藏标题栏 |
| 文件选择 | `file_picker` | 文件夹选取 |
| 工具 | `path`, `path_provider`, `collection` | 路径处理、应用目录 |

---

## 1. 基础设施层 (Infrastructure)

### 1.1 DatabaseService
> 路径：`core/database/database_service.dart`

单例管理 Isar 数据库实例，注册 `Song`、`Playlist`、`LibraryFolder` 三个 Schema。

| 方法 | 类型 | 说明 |
|:---|:---|:---|
| `initialize()` | `static Future<void>` | 初始化数据库，若损坏自动重建 |
| `instance` | `static Isar` (getter) | 获取全局 Isar 实例 |
| `close()` | `static Future<void>` | 关闭数据库 |
| `clearAll()` | `static Future<void>` | 清空所有数据 (开发用) |

数据库路径：`{文档目录}\my_music_player\mymp_db`

### 1.2 外部依赖初始化
> 路径：`main.dart`

启动顺序：
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `MediaKit.ensureInitialized()` — 初始化 media_kit 播放引擎
3. `windowManager.ensureInitialized()` — 窗口配置 (1280×800, 最小 960×600, 隐藏标题栏)
4. `DatabaseService.initialize()` — 初始化数据库
5. `runApp(ProviderScope(child: MyMusicPlayerApp()))` — 启动应用

---

## 2. 数据模型层 (Models)

> 路径：`data/models/`  
> 导出文件：`data/models/models.dart`

### 2.1 Song
> 文件：`data/models/song.dart`

歌曲实体，Isar `@collection`。

| 字段 | 类型 | 索引 | 说明 |
|:---|:---|:---|:---|
| `id` | `Id` | 主键(自增) | Isar 自增主键 |
| `filePath` | `String` | `@Index(unique: true)` | 文件完整路径 |
| `title` | `String` | `@Index()` | 歌曲标题 |
| `artist` | `String` | `@Index()` | 艺术家 |
| `album` | `String` | `@Index()` | 专辑名 |
| `albumArtist` | `String?` | — | 专辑艺术家 |
| `year` | `int?` | — | 发行年份 |
| `durationMs` | `int?` | — | 时长(毫秒) |
| `bitrate` | `int?` | — | 比特率(kbps) |
| `sampleRate` | `int?` | — | 采样率(Hz) |
| `fileSize` | `int?` | — | 文件大小(字节) |
| `modifiedTime` | `DateTime` | `@Index()` | 文件修改时间 |
| `coverBytes` | `List<byte>?` | — | 封面二进制数据 |
| `trackNumber` | `int?` | — | 音轨编号 |
| `discNumber` | `int?` | — | 碟片编号 |
| `createdAt` | `DateTime` | — | 创建时间 |
| `updatedAt` | `DateTime` | — | 更新时间 |

**工厂/工具方法**：
- `Song.fromMetadata({...})` — 从扫描元数据创建
- `formattedDuration` (getter) — 格式化时长 `mm:ss`

### 2.2 Playlist
> 文件：`data/models/playlist.dart`

歌单实体，Isar `@collection`。

| 字段 | 类型 | 索引 | 说明 |
|:---|:---|:---|:---|
| `id` | `Id` | 主键(自增) | |
| `name` | `String` | `@Index()` | 歌单名称 |
| `songIds` | `List<int>` | — | 有序歌曲 ID 列表 |
| `description` | `String?` | — | 歌单描述 |
| `coverBytes` | `List<byte>?` | — | 封面图片 |
| `createdAt` | `DateTime` | — | |
| `updatedAt` | `DateTime` | — | |

**实例方法**：
- `songCount` (getter) — 歌曲数
- `addSong(songId)` / `addSongs(ids)` — 添加歌曲（自动去重）
- `removeSong(songId)` / `removeSongs(ids)` — 移除歌曲
- `reorderSongs(oldIndex, newIndex)` — 重排序

**工厂**：
- `Playlist.create({name, description?})` — 创建新歌单

### 2.3 LibraryFolder
> 文件：`data/models/library_folder.dart`

音乐库文件夹实体，Isar `@collection`。

| 字段 | 类型 | 索引 | 说明 |
|:---|:---|:---|:---|
| `id` | `Id` | 主键(自增) | |
| `path` | `String` | `@Index(unique: true)` | 文件夹路径 |
| `displayName` | `String` | — | 显示名（最后一级目录名） |
| `lastScanTime` | `DateTime?` | — | 上次扫描时间 |
| `songCount` | `int` | — | 歌曲数量 |
| `isEnabled` | `bool` | — | 是否启用 |
| `createdAt` | `DateTime` | — | |

**方法**：
- `LibraryFolder.fromPath(path)` — 从路径创建
- `updateScanInfo({scanTime, count})` — 更新扫描信息
- `formattedLastScan` (getter) — 格式化扫描时间

### 2.4 辅助数据类型

| 类 | 定义位置 | 说明 |
|:---|:---|:---|
| `AlbumInfo` | `song_repository.dart` | 专辑聚合 (name, artist, year?, songCount, coverBytes?) |
| `ArtistInfo` | `song_repository.dart` | 艺术家聚合 (name, songCount, albumCount) |
| `PlaylistWithSongs` | `playlist_repository.dart` | 歌单+歌曲列表 (totalDurationMs, formattedTotalDuration) |
| `AudioMetadata` | `metadata_service.dart` | 元数据传输对象 (title, artist, album, ..., copyWith) |
| `ScanProgress` | `library_scan_service.dart` | 扫描进度 (phase, current, total, currentFile, percentage, description) |
| `ScanPhase` | `library_scan_service.dart` | 扫描阶段枚举 (scanning, parsing, completed) |
| `QueueState` | `queue_provider.dart` | 播放队列状态 (queue, currentIndex, loopMode, shuffleOrder, ...) |
| `LoopMode` | `queue_provider.dart` | 循环模式枚举 (off, all, one, shuffle) |
| `ScanState` | `scan_provider.dart` | 扫描状态 (isScanning, progress?, error?) |
| `NavRoute` | `navigation_provider.dart` | 导航路由 (viewType, detailId?, title?) |
| `NavViewType` | `navigation_provider.dart` | 视图类型枚举 (albums, artists, playlists, folders, settings*) |

---

## 3. 仓库层 (Repositories)

> 路径：`data/repositories/`  
> 导出文件：`data/repositories/repositories.dart`

### 3.1 SongRepository
> 文件：`data/repositories/song_repository.dart`

| 分类 | 方法签名 | 返回类型 | 说明 |
|:---|:---|:---|:---|
| **查询** | `getAllSongs()` | `Future<List<Song>>` | 全部歌曲 |
| | `getSongById(int id)` | `Future<Song?>` | 按 ID |
| | `getSongByPath(String path)` | `Future<Song?>` | 按文件路径 |
| | `getSongsByAlbum(String albumName)` | `Future<List<Song>>` | 按专辑 |
| | `getSongsByArtist(String artistName)` | `Future<List<Song>>` | 按艺术家 |
| | `getSongsByFolder(String folderPath)` | `Future<List<Song>>` | 按文件夹前缀匹配 |
| | `getSongsByIds(List<int> ids)` | `Future<List<Song>>` | 批量按 ID |
| | `searchSongs(String keyword)` | `Future<List<Song>>` | 模糊搜索 (标题/专辑/艺术家) |
| | `getAllAlbums()` | `Future<List<String>>` | 所有专辑名(去重排序) |
| | `getAllArtists()` | `Future<List<String>>` | 所有艺术家名(去重排序) |
| | `getSongCount()` | `Future<int>` | 歌曲总数 |
| **聚合** | `getAlbumInfoList()` | `Future<List<AlbumInfo>>` | 专辑聚合信息 |
| | `getArtistInfoList()` | `Future<List<ArtistInfo>>` | 艺术家聚合信息 |
| **写入** | `upsertSong(Song song)` | `Future<int>` | 插入或更新(按 filePath 匹配) |
| | `upsertSongs(List<Song> songs)` | `Future<List<int>>` | 批量 upsert |
| | `deleteSong(int id)` | `Future<bool>` | 按 ID 删除 |
| | `deleteSongByPath(String path)` | `Future<bool>` | 按路径删除 |
| | `deleteSongs(List<int> ids)` | `Future<int>` | 批量删除 |
| | `deleteSongsByFolder(String path)` | `Future<int>` | 删除文件夹下所有 |
| | `deleteAllSongs()` | `Future<void>` | 清空 |

### 3.2 PlaylistRepository
> 文件：`data/repositories/playlist_repository.dart`

| 分类 | 方法签名 | 返回类型 | 说明 |
|:---|:---|:---|:---|
| **查询** | `getAllPlaylists()` | `Future<List<Playlist>>` | 全部歌单 |
| | `getPlaylistById(int id)` | `Future<Playlist?>` | 按 ID |
| | `getPlaylistByName(String name)` | `Future<Playlist?>` | 按名称 |
| | `getPlaylistWithSongs(int id)` | `Future<PlaylistWithSongs?>` | 歌单+歌曲列表 |
| | `getPlaylistCount()` | `Future<int>` | 歌单总数 |
| **写入** | `createPlaylist({name, description?})` | `Future<int>` | 创建，返回 ID |
| | `updatePlaylist(Playlist)` | `Future<int>` | 更新 |
| | `renamePlaylist(int id, String newName)` | `Future<bool>` | 重命名 |
| | `deletePlaylist(int id)` | `Future<bool>` | 删除 |
| | `addSongsToPlaylist(int playlistId, List<int> songIds)` | `Future<bool>` | 添加歌曲(自动去重) |
| | `removeSongsFromPlaylist(int playlistId, List<int> songIds)` | `Future<bool>` | 移除歌曲 |
| | `reorderSongsInPlaylist(int playlistId, int oldIndex, int newIndex)` | `Future<bool>` | 重排序 |
| | `clearPlaylist(int playlistId)` | `Future<bool>` | 清空歌单 |
| | `setPlaylistCover(int playlistId, List<int>? coverBytes)` | `Future<bool>` | 设置封面 |
| | `removeSongFromAllPlaylists(int songId)` | `Future<void>` | 从所有歌单移除 |
| | `removeSongsFromAllPlaylists(List<int> songIds)` | `Future<void>` | 批量从所有歌单移除 |

### 3.3 LibraryFolderRepository
> 文件：`data/repositories/library_folder_repository.dart`

| 分类 | 方法签名 | 返回类型 | 说明 |
|:---|:---|:---|:---|
| **查询** | `getAllFolders()` | `Future<List<LibraryFolder>>` | 全部文件夹 |
| | `getEnabledFolders()` | `Future<List<LibraryFolder>>` | 启用的文件夹 |
| | `getFolderById(int id)` | `Future<LibraryFolder?>` | 按 ID |
| | `getFolderByPath(String path)` | `Future<LibraryFolder?>` | 按路径 |
| | `folderExists(String path)` | `Future<bool>` | 是否已存在 |
| | `getFolderCount()` | `Future<int>` | 总数 |
| **写入** | `addFolder(String path)` | `Future<int>` | 添加(已存在返回现有 ID) |
| | `removeFolder(int id)` | `Future<bool>` | 按 ID 删除 |
| | `removeFolderByPath(String path)` | `Future<bool>` | 按路径删除 |
| | `updateScanInfo(int id, {scanTime, songCount})` | `Future<bool>` | 更新扫描信息 |
| | `toggleFolderEnabled(int id)` | `Future<bool>` | 切换启用状态 |
| | `setFolderEnabled(int id, bool enabled)` | `Future<bool>` | 设置启用状态 |
| | `clearAllFolders()` | `Future<void>` | 清空 |

---

## 4. 服务层 (Services)

> 路径：`data/services/`  
> 导出文件：`data/services/services.dart`

### 4.1 PlayerService *(Phase 2 新增)*
> 文件：`data/services/player_service.dart`  
> 封装 `media_kit` 的 `Player` 实例。

| 分类 | 方法/属性 | 类型 | 说明 |
|:---|:---|:---|:---|
| **属性** | `player` | `Player` (getter) | 底层 media_kit Player 实例 |
| | `isInitialized` | `bool` | 是否已初始化 |
| | `currentFilePath` | `String?` | 当前文件路径 |
| **播放控制** | `open(String filePath)` | `Future<void>` | 打开并播放文件 |
| | `play()` | `Future<void>` | 播放 |
| | `pause()` | `Future<void>` | 暂停 |
| | `playOrPause()` | `Future<void>` | 播放/暂停切换 |
| | `stop()` | `Future<void>` | 停止并清除当前文件 |
| | `seek(Duration position)` | `Future<void>` | 跳转到指定位置 |
| | `setVolume(double volume)` | `Future<void>` | 设置音量 (0.0-1.0 → 内部 0-100) |
| **状态 Getter** | `volume` | `double` | 当前音量 (0.0-1.0) |
| | `isPlaying` | `bool` | 是否播放中 |
| | `position` | `Duration` | 当前位置 |
| | `duration` | `Duration` | 总时长 |
| | `isCompleted` | `bool` | 是否已播完 |
| **状态流** | `playingStream` | `Stream<bool>` | 播放状态流 |
| | `positionStream` | `Stream<Duration>` | 位置流 |
| | `durationStream` | `Stream<Duration>` | 时长流 |
| | `bufferStream` | `Stream<Duration>` | 缓冲流 |
| | `volumeStream` | `Stream<double>` | 音量流 (已归一化 0.0-1.0) |
| | `completedStream` | `Stream<bool>` | 播完事件流 |
| | `playlistStream` | `Stream<Playlist>` | media_kit 内部播放列表流 |
| **生命周期** | `dispose()` | `Future<void>` | 释放资源 |

### 4.2 LibraryScanService
> 文件：`data/services/library_scan_service.dart`  
> 支持的格式：`.mp3`, `.flac`, `.wav`, `.m4a`, `.aac`, `.ogg`

| 方法 | 返回类型 | 说明 |
|:---|:---|:---|
| `scanFolder({folderPath, songRepository, folderRepository, onProgress?})` | `Future<int>` | 全量扫描单个文件夹 |
| `incrementalScanFolder({folderPath, songRepo, folderRepo, playlistRepo, onProgress?})` | `Future<int>` | 增量扫描 (新增/修改/删除) |
| `scanAllFolders({songRepo, folderRepo, playlistRepo, onProgress?, incremental?})` | `Future<int>` | 扫描所有文件夹 |

**增量扫描逻辑**：
1. 收集当前音频文件列表
2. 与数据库对比 → 分类为新增 / 修改(modifiedTime 比较) / 删除
3. 删除已移除文件的数据库记录，并清理歌单中的引用
4. 解析新增/修改文件的元数据，批量 upsert

### 4.3 MetadataService
> 文件：`data/services/metadata_service.dart`  
> 基于 `audiotags` (TagLib)。

| 方法 | 返回类型 | 说明 |
|:---|:---|:---|
| `readMetadata(String filePath)` | `Future<AudioMetadata?>` | 读取音频元数据 |
| `writeMetadata(String filePath, AudioMetadata metadata)` | `Future<bool>` | 写入元数据到文件 (合并现有数据) |
| `extractCover(String filePath)` | `Future<Uint8List?>` | 提取封面图片 |
| `setCover(String filePath, Uint8List imageBytes)` | `Future<bool>` | 设置封面图片 |
| `batchWriteMetadata(List<String> filePaths, AudioMetadata metadata)` | `Future<List<String>>` | 批量写入，返回失败路径列表 |

**已知限制**：`audiotags` 不直接提供 `bitrate` 和 `sampleRate`，这两个字段目前始终为 `null`。

### 4.4 PlaylistIOService
> 文件：`data/services/playlist_io_service.dart`  
> 通过构造函数注入 `SongRepository` 和 `PlaylistRepository`。

| 方法 | 返回类型 | 说明 |
|:---|:---|:---|
| `exportToM3U(int playlistId, String outputPath, {useRelativePaths = true})` | `Future<bool>` | 导出歌单为 M3U 文件 |
| `importFromM3U(String filePath, {playlistName?})` | `Future<int?>` | 从 M3U 导入，返回歌单 ID |

**导出格式**：`#EXTM3U` + `#PLAYLIST:名称` + `#EXTINF:秒,Artist - Title` + 路径  
**导入处理**：自动识别相对/绝对路径，支持 GBK 编码回退，不区分大小写匹配文件路径

---

## 5. 状态层 (Providers)

> 路径：`providers/`  
> 导出文件：`providers/providers.dart`（注意：不含 `player_provider.dart` 和 `queue_provider.dart`）

### 5.1 核心 Providers (core_providers.dart)

| Provider | 类型 | 说明 |
|:---|:---|:---|
| `songRepositoryProvider` | `Provider<SongRepository>` | 歌曲仓库单例 |
| `playlistRepositoryProvider` | `Provider<PlaylistRepository>` | 歌单仓库单例 |
| `libraryFolderRepositoryProvider` | `Provider<LibraryFolderRepository>` | 文件夹仓库单例 |
| `libraryScanServiceProvider` | `Provider<LibraryScanService>` | 扫描服务单例 |
| `metadataServiceProvider` | `Provider<MetadataService>` | 元数据服务单例 |
| `playlistIOServiceProvider` | `Provider<PlaylistIOService>` | 歌单导入导出服务 (注入依赖) |

### 5.2 播放器 Providers (player_provider.dart) *(Phase 2 新增)*

| Provider | 类型 | 说明 |
|:---|:---|:---|
| `playerServiceProvider` | `Provider<PlayerService>` | 播放器服务单例 (自动 dispose) |
| `currentSongProvider` | `StateProvider<Song?>` | 当前播放歌曲 |
| `isPlayingProvider` | `StreamProvider<bool>` | 播放状态流 |
| `playerPositionProvider` | `StreamProvider<Duration>` | 播放位置流 |
| `playerDurationProvider` | `StreamProvider<Duration>` | 歌曲时长流 |
| `playerVolumeProvider` | `StreamProvider<double>` | 音量流 (0.0-1.0) |
| `playerCompletedProvider` | `StreamProvider<bool>` | 播放完成事件流 |
| `playerNotifierProvider` | `StateNotifierProvider<PlayerNotifier, AsyncValue<void>>` | 播放控制 Notifier |
| `playerActionsProvider` | `Provider<PlayerNotifier>` | 便捷访问播放控制方法 |

**PlayerNotifier 方法**：

| 方法 | 说明 |
|:---|:---|
| `playSong(Song song)` | 直接播放指定歌曲 (不经过队列) |
| `playOrPause()` | 播放/暂停切换 |
| `play()` / `pause()` | 播放 / 暂停 |
| `stop()` | 停止并清除 currentSong |
| `seek(Duration position)` | 跳转进度 |
| `setVolume(double volume)` | 设置音量 |

### 5.3 播放队列 Providers (queue_provider.dart) *(Phase 2 新增)*

| Provider | 类型 | 说明 |
|:---|:---|:---|
| `queueProvider` | `StateNotifierProvider<QueueNotifier, QueueState>` | 队列核心状态 |
| `loopModeProvider` | `Provider<LoopMode>` | 当前循环模式 |
| `hasNextProvider` | `Provider<bool>` | 是否有下一首 |
| `hasPreviousProvider` | `Provider<bool>` | 是否有上一首 |
| `queueSongsProvider` | `Provider<List<Song>>` | 队列歌曲列表 |
| `queueCurrentIndexProvider` | `Provider<int>` | 队列当前索引 |

**QueueNotifier 方法**：

| 方法 | 说明 |
|:---|:---|
| `playSingle(Song song)` | 清空队列，播放单曲 |
| `playList(List<Song> songs, {startIndex})` | 用歌曲列表替换队列并播放 |
| `addToQueue(Song song)` | 添加到队列末尾 |
| `addAllToQueue(List<Song> songs)` | 批量添加到末尾 |
| `insertNext(Song song)` | 插入为"下一首播放" |
| `removeFromQueue(int index)` | 按索引移除 |
| `clearQueue()` | 清空队列 |
| `skipToIndex(int index)` | 跳转到指定索引 |
| `next()` | 下一首 (按循环模式处理) |
| `previous()` | 上一首 (播放>3秒先回到开头) |
| `toggleLoopMode()` | 循环切换：off → all → one → shuffle |
| `setLoopMode(LoopMode mode)` | 设置指定循环模式 |

**LoopMode 逻辑**：
- `off` — 顺序播放，到末尾停止
- `all` — 列表循环
- `one` — 单曲循环 (播完自动重播)
- `shuffle` — 生成随机顺序，支持前后导航

### 5.4 音乐库 Providers (library_provider.dart)

| Provider | 类型 | 说明 |
|:---|:---|:---|
| `songsProvider` | `FutureProvider<List<Song>>` | 所有歌曲 (无刷新监听) |
| `albumsProvider` | `FutureProvider<List<AlbumInfo>>` | 专辑聚合 (无刷新监听) |
| `artistsProvider` | `FutureProvider<List<ArtistInfo>>` | 艺术家聚合 (无刷新监听) |
| `foldersProvider` | `FutureProvider<List<LibraryFolder>>` | 文件夹列表 (无刷新监听) |
| `songCountProvider` | `FutureProvider<int>` | 歌曲总数 |
| `songsByAlbumProvider` | `FutureProvider.family<List<Song>, String>` | 按专辑筛选 |
| `songsByArtistProvider` | `FutureProvider.family<List<Song>, String>` | 按艺术家筛选 |
| `songsByFolderProvider` | `FutureProvider.family<List<Song>, String>` | 按文件夹筛选 |
| `libraryRefreshProvider` | `StateNotifierProvider<LibraryRefreshNotifier, int>` | 刷新触发器 (调用 `.refresh()`) |
| `refreshableSongsProvider` | `FutureProvider<List<Song>>` | 可刷新的歌曲列表 |
| `refreshableAlbumsProvider` | `FutureProvider<List<AlbumInfo>>` | 可刷新的专辑列表 |
| `refreshableArtistsProvider` | `FutureProvider<List<ArtistInfo>>` | 可刷新的艺术家列表 |
| `refreshableFoldersProvider` | `FutureProvider<List<LibraryFolder>>` | 可刷新的文件夹列表 |

**刷新机制**：`libraryRefreshProvider` 的 `state++` 触发所有 `ref.watch(libraryRefreshProvider)` 的 Provider 重新计算。

### 5.5 歌单 Providers (playlist_provider.dart)

| Provider | 类型 | 说明 |
|:---|:---|:---|
| `playlistsProvider` | `FutureProvider<List<Playlist>>` | 所有歌单 (监听 libraryRefresh) |
| `playlistValidSongCountProvider` | `FutureProvider.family<int, int>` | 歌单有效歌曲数 (按 playlistId) |
| `selectedPlaylistIdProvider` | `StateProvider<int?>` | 当前选中歌单 ID |
| `selectedPlaylistWithSongsProvider` | `FutureProvider<PlaylistWithSongs?>` | 选中歌单详情 |
| `playlistManagerProvider` | `StateNotifierProvider<PlaylistManagerNotifier, AsyncValue<void>>` | 歌单管理 |
| `playlistActionsProvider` | `Provider<PlaylistManagerNotifier>` | 便捷访问 |

**PlaylistManagerNotifier 方法**：`createPlaylist`, `deletePlaylist`, `renamePlaylist`, `addSongsToPlaylist`, `removeSongsFromPlaylist`, `reorderSongs` — 每个操作后自动调用 `libraryRefreshProvider.refresh()`。

### 5.6 导航 Providers (navigation_provider.dart)

| Provider | 类型 | 说明 |
|:---|:---|:---|
| `navigationProvider` | `StateNotifierProvider<NavigationNotifier, NavRoute>` | 导航状态 |
| `currentViewTypeProvider` | `Provider<NavViewType>` | 当前视图类型 |
| `canGoBackProvider` | `Provider<bool>` | 是否可后退 |
| `canGoForwardProvider` | `Provider<bool>` | 是否可前进 |

**NavigationNotifier 方法**：`navigateTo(route)`, `navigateToView(viewType)`, `navigateToDetail(viewType, detailId, {title?})`, `goBack()`, `goForward()`, `reset()`

**NavViewType 枚举**：`albums`, `artists`, `playlists`, `folders`, `settingsStorage`, `settingsAbout`, `settingsLanguage`

### 5.7 扫描 Providers (scan_provider.dart)

| Provider | 类型 | 说明 |
|:---|:---|:---|
| `scanProvider` | `StateNotifierProvider<ScanNotifier, ScanState>` | 扫描状态 |
| `isScanningProvider` | `Provider<bool>` | 是否正在扫描 |
| `scanProgressProvider` | `Provider<ScanProgress?>` | 当前进度 |

**ScanNotifier 方法**：`scanAllFolders({incremental?})`, `scanFolder(path, {incremental?})`, `addFolderAndScan(path)`, `clearError()`

### 5.8 搜索 Providers (search_provider.dart)

| Provider | 类型 | 说明 |
|:---|:---|:---|
| `searchQueryProvider` | `StateProvider<String>` | 搜索关键词 |
| `searchResultsProvider` | `FutureProvider<List<Song>>` | 搜索结果 |
| `isSearchActiveProvider` | `StateProvider<bool>` | 搜索是否激活 |
| `searchHistoryProvider` | `StateNotifierProvider<SearchHistoryNotifier, List<String>>` | 搜索历史 (内存中，最多 10 条) |

---

## 6. 表现层 (UI)

> 路径：`ui/`

### 6.1 布局 (`ui/layouts/`)

| 组件 | 文件 | 说明 |
|:---|:---|:---|
| `MainLayout` | `main_layout.dart` | 应用主布局：左侧 Sidebar + 右侧 (TopControlBar + MainContent) + 底部 BottomPlayerBar + 可选右侧 QueuePanel |

**MainLayout 结构**：
```
Column
├── Expanded (Row)
│   ├── AnimatedContainer (Sidebar, 可折叠 220px/0px)
│   ├── Expanded (Column)
│   │   ├── TopControlBar
│   │   └── Expanded (内容区，按 NavRoute 路由)
│   └── QueuePanel (条件显示, 320px)
└── BottomPlayerBar (72px)
```

**路由映射** (navRoute → View)：

| NavViewType | detailId == null | detailId != null |
|:---|:---|:---|
| `albums` | `AlbumView` | `AlbumDetailView` |
| `artists` | `ArtistView` | `ArtistDetailView` |
| `playlists` | `PlaylistView` | `PlaylistDetailView` |
| `folders` | `FolderView` | `FolderDetailView` |
| `settingsStorage` | `StorageSettingsView` | — |
| `settingsAbout` | 占位 `Center(text)` | — |
| `settingsLanguage` | 占位 `Center(text)` | — |

### 6.2 通用组件 (`ui/widgets/`)

| 组件 | 文件 | 说明 |
|:---|:---|:---|
| `TopControlBar` | `top_control_bar.dart` | 顶部栏：导航后退/前进、侧边栏开关、搜索、窗口控制 (DragToMoveArea) |
| `Sidebar` | `sidebar.dart` | 左侧导航：音乐库 (专辑/作者/歌单/文件夹) + 设置 (存储/关于/语言字体) |
| `BottomPlayerBar` | `bottom_player_bar.dart` | 底部播放栏 (72px)：左侧封面+信息 / 中部控制+进度条 / 右侧音量+队列按钮 |
| `QueuePanel` | `queue_panel.dart` | 右侧播放队列面板 (320px)：歌曲列表、循环模式切换、清空 |
| `BatchEditDialog` | `batch_edit_dialog.dart` | 批量编辑元数据对话框：标题/艺术家/专辑/年份，写入文件+同步数据库 |
| `PlaylistSelectorDialog` | `playlist_selector_dialog.dart` | 歌单选择器对话框：选择已有歌单或新建歌单，添加歌曲 |

**BottomPlayerBar 功能细节** (Phase 2)：
- 左侧 (280px)：封面缩略图 (缓存避免闪烁) + 歌名 + 歌手
- 中部：上一首/播放暂停/下一首 按钮 + 进度条 (支持拖拽, Tooltip 时间预览) + 循环模式切换
- 右侧：音量悬浮控制 (`_VolumeOverlay`，鼠标悬停显示竖向滑块) + 队列面板开关
- 监听 Providers：`currentSongProvider`, `isPlayingProvider`, `playerPositionProvider`, `playerDurationProvider`, `playerVolumeProvider`

**QueuePanel 功能** (Phase 2)：
- 标题栏显示队列歌曲数 + 循环模式按钮 + 清空按钮
- 歌曲列表：点击跳转播放、当前歌曲高亮、右键/hover 移除
- 由 `queuePanelVisibleProvider` (`StateProvider<bool>`) 控制显隐

### 6.3 视图页面 (`ui/views/`)

| 视图 | 文件 | 说明 |
|:---|:---|:---|
| `AlbumView` | `album_view.dart` | 专辑网格视图 (封面+名称+歌曲数) |
| `AlbumDetailView` | `album_detail_view.dart` | 专辑详情 (封面+歌曲列表+批量操作) |
| `ArtistView` | `artist_view.dart` | 艺术家列表视图 |
| `ArtistDetailView` | `artist_detail_view.dart` | 艺术家详情 (歌曲列表) |
| `PlaylistView` | `playlist_view.dart` | 歌单列表 (创建/删除/导入M3U/导出M3U) |
| `PlaylistDetailView` | `playlist_detail_view.dart` | 歌单详情 (歌曲列表+添加/移除/重排序+批量操作) |
| `FolderView` | `folder_view.dart` | 文件夹列表视图 |
| `FolderDetailView` | `folder_detail_view.dart` | 文件夹详情 (歌曲列表) |
| `StorageSettingsView` | `storage_settings_view.dart` | 存储设置 (管理音乐文件夹、触发扫描) |

### 6.4 主题 (`ui/theme/`)

| 文件 | 说明 |
|:---|:---|
| `app_theme.dart` | ZZZ 风格深色主题定义 |

**颜色系统**：

| 常量 | 色值 | 用途 |
|:---|:---|:---|
| `primaryColor` | `#E53935` | 主色调 (红) |
| `secondaryColor` | `#00E5FF` | 次要色 (电光蓝) |
| `backgroundColor` | `#0A0A0A` | 深黑背景 |
| `surfaceColor` | `#1A1A1A` | 表面色 |
| `cardColor` | `#242424` | 卡片背景 |
| `sidebarColor` | `#121212` | 侧边栏 |
| `playerBarColor` | `#181818` | 播放栏 |
| `textPrimary` | `#FFFFFF` | 主文本 |
| `textSecondary` | `#B0B0B0` | 次要文本 |
| `textDisabled` | `#606060` | 禁用文本 |
| `dividerColor` | `#2A2A2A` | 分割线 |
| `hoverColor` | `#2D2D2D` | 悬停背景 |
| `activeColor` | `#E53935` | 选中/激活色 |

---

## 7. 开发状态对照表

根据需求文档的开发阶段规划，标注各功能模块的当前实现状态：

### Phase 1 — 核心数据层 ✅ 已完成

| 需求 ID | 功能 | 状态 |
|:---|:---|:---|
| LIB-01 | 本地源管理 (添加/删除/全量/增量扫描) | ✅ 已完成 |
| LIB-02 | 多维视图 (专辑/作者/文件夹/歌单) | ✅ 已完成 |
| LIB-03 | 自建歌单 (CRUD、添加歌曲) | ✅ 已完成 |
| LIB-04 | 全局搜索 (模糊匹配) | ⚠️ Provider 已实现，UI 搜索浮层待完善 (Phase 4.5) |
| LIB-05 | 元数据编辑 (单曲/批量) | ✅ 已完成 |
| LIB-06 | 播放列表持久化 (M3U 导入导出) | ✅ 已完成 |
| 1.6.2 | 导航历史 (后退/前进) | ✅ 已完成 |
| 1.6.3 | 数据同步优化 | ✅ 已完成 |
| 1.6.4 | 批量操作 (编辑/添加歌单) | ✅ 已完成 |

### Phase 2 — 播放功能 🔄 进行中

| 需求 ID | 功能 | 状态 |
|:---|:---|:---|
| PLY-01 | 格式解码 (media_kit 集成) | ✅ 已完成 |
| PLY-04 | 循环模式 (off/all/one/shuffle) | ✅ 已完成 |
| PLY-07 | 播放控制 (播放/暂停/上下曲/进度拖拽) | ✅ 已完成 |
| PLY-03 | 播放队列 (队列管理/下一首播放) | ✅ 已完成 (QueuePanel + QueueNotifier) |
| PLY-07 | SMTC (Windows 系统媒体控制) | ❌ 未实现 |
| 4.5-B | 底部播放栏 UI | ✅ 已完成 (但封面闪烁问题已尝试用缓存解决) |
| — | QueuePanel 右侧面板 | ✅ 已完成 |

### Phase 3 — 完善播放器 ❌ 未开始

| 需求 ID | 功能 | 状态 |
|:---|:---|:---|
| PLY-02 | 参数监视 (码率/采样率) | ❌ (bitrate/sampleRate 字段目前为 null) |
| PLY-06 | 信号路径 | ❌ |
| PLY-05 | 定时停止 | ❌ |
| 4.6 | 沉浸式播放页面 | ❌ |

### Phase 4 — 可视化与完善 ❌ 未开始

| 需求 ID | 功能 | 状态 |
|:---|:---|:---|
| VIS-01 | 歌词渲染 | ❌ |
| VIS-02~07 | 歌词设置/翻译/频谱/波形/查找 | ❌ |
| LIB-04 | 全局搜索全功能 | ⚠️ 部分 |
| Settings | 关于/语言字体 | ❌ 占位中 |

---

## 8. 已知问题与待办

| 类别 | 问题 | 备注 |
|:---|:---|:---|
| **数据** | `bitrate` / `sampleRate` 始终为 null | `audiotags` 不提供，需换用其他方式获取 (如 media_kit `AudioParams`) |
| **UI** | 底部播放栏封面在播放时可能闪烁 | 已通过缓存 `_cachedCoverBytes` 缓解，但仍有报告 |
| **UI** | 详情页封面不显示 | 手动记录中提到 |
| **UI** | 设置页 "关于" 和 "语言与字体" 为占位 | Phase 4 实现 |
| **功能** | 多作者读取逻辑未处理 | `artist` 字段当前为单字符串 |
| **功能** | 左侧侧边栏不支持自定义编辑 | |
| **集成** | 缺少 SMTC 集成 | Phase 2 计划中，需引入 `smtc_windows` 包 |
| **架构** | `providers.dart` 导出文件未包含 `player_provider.dart` 和 `queue_provider.dart` | 各 UI 文件直接 import |
| **架构** | 部分 Provider 同时存在无刷新版和可刷新版 (如 `songsProvider` vs `refreshableSongsProvider`) | 建议统一使用可刷新版 |

---

## 9. 快速参考代码片段

### 播放一首歌曲 (通过队列)
```dart
ref.read(queueProvider.notifier).playSingle(song);
```

### 播放歌曲列表
```dart
ref.read(queueProvider.notifier).playList(songs, startIndex: 0);
```

### 播放/暂停
```dart
ref.read(playerActionsProvider).playOrPause();
```

### 上一首/下一首
```dart
ref.read(queueProvider.notifier).previous();
ref.read(queueProvider.notifier).next();
```

### 获取当前播放状态
```dart
final isPlaying = ref.watch(isPlayingProvider).valueOrNull ?? false;
final position = ref.watch(playerPositionProvider).valueOrNull ?? Duration.zero;
final duration = ref.watch(playerDurationProvider).valueOrNull ?? Duration.zero;
final currentSong = ref.watch(currentSongProvider);
```

### 切换循环模式
```dart
ref.read(queueProvider.notifier).toggleLoopMode();
```

### 插入为下一首播放
```dart
ref.read(queueProvider.notifier).insertNext(song);
```

### 控制队列面板显隐
```dart
ref.read(queuePanelVisibleProvider.notifier).state = !ref.read(queuePanelVisibleProvider);
```

### 获取歌曲列表 (可刷新)
```dart
final songs = ref.watch(refreshableSongsProvider);
```

### 导航到详情页
```dart
ref.read(navigationProvider.notifier).navigateToDetail(NavViewType.albums, albumName, title: albumName);
```

### 触发全量扫描
```dart
await ref.read(scanProvider.notifier).scanAllFolders(incremental: false);
```

### 编辑元数据
```dart
final service = ref.read(metadataServiceProvider);
await service.writeMetadata(filePath, AudioMetadata(title: '新标题'));
```

### 添加歌曲到歌单
```dart
await ref.read(playlistActionsProvider).addSongsToPlaylist(playlistId, songIds);
```
