# Phase 1 功能接口总结
> **目的**：记录 Phase 1 已实现的所有可复用接口，避免后续开发重复造轮子。
> **最后更新**：2026-02-04

---

## 1. 数据模型 (Models)

| 模型 | 文件 | 说明 |
|------|------|------|
| `Song` | `data/models/song.dart` | 歌曲实体，含标题/艺术家/专辑/时长/封面等 |
| `Playlist` | `data/models/playlist.dart` | 歌单实体，含名称/歌曲ID列表/封面 |
| `LibraryFolder` | `data/models/library_folder.dart` | 音乐库文件夹，含路径/启用状态/扫描时间 |

---

## 2. 仓库层 (Repositories)

### 2.1 SongRepository
> 路径：`data/repositories/song_repository.dart`

**查询方法**：
| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `getAllSongs()` | `List<Song>` | 获取所有歌曲 |
| `getSongById(id)` | `Song?` | 按 ID 获取 |
| `getSongByPath(path)` | `Song?` | 按文件路径获取 |
| `getSongsByAlbum(albumName)` | `List<Song>` | 按专辑名获取 |
| `getSongsByArtist(artistName)` | `List<Song>` | 按艺术家名获取 |
| `getSongsByFolder(folderPath)` | `List<Song>` | 按文件夹路径前缀匹配 |
| `getSongsByIds(ids)` | `List<Song>` | 按 ID 列表批量获取 |
| `searchSongs(keyword)` | `List<Song>` | 模糊搜索（标题/专辑/艺术家） |
| `getAlbumInfoList()` | `List<AlbumInfo>` | 获取专辑聚合信息 |
| `getArtistInfoList()` | `List<ArtistInfo>` | 获取艺术家聚合信息 |
| `getSongCount()` | `int` | 获取歌曲总数 |

**写入方法**：
| 方法 | 说明 |
|------|------|
| `upsertSong(song)` | 插入或更新单曲 |
| `upsertSongs(songs)` | 批量插入或更新 |
| `deleteSong(id)` | 按 ID 删除 |
| `deleteSongByPath(path)` | 按路径删除 |
| `deleteSongs(ids)` | 批量删除 |
| `deleteSongsByFolder(path)` | 删除文件夹下所有歌曲 |
| `deleteAllSongs()` | 清空所有歌曲 |

---

### 2.2 PlaylistRepository
> 路径：`data/repositories/playlist_repository.dart`

**查询方法**：
| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `getAllPlaylists()` | `List<Playlist>` | 获取所有歌单 |
| `getPlaylistById(id)` | `Playlist?` | 按 ID 获取 |
| `getPlaylistByName(name)` | `Playlist?` | 按名称获取 |
| `getPlaylistWithSongs(id)` | `PlaylistWithSongs?` | 获取歌单及其歌曲列表 |
| `getPlaylistCount()` | `int` | 获取歌单总数 |

**写入方法**：
| 方法 | 说明 |
|------|------|
| `createPlaylist(name, description?)` | 创建新歌单 |
| `updatePlaylist(playlist)` | 更新歌单信息 |
| `renamePlaylist(id, newName)` | 重命名歌单 |
| `deletePlaylist(id)` | 删除歌单 |
| `addSongsToPlaylist(playlistId, songIds)` | 添加歌曲到歌单 |
| `removeSongsFromPlaylist(playlistId, songIds)` | 从歌单移除歌曲 |
| `reorderSongsInPlaylist(playlistId, oldIndex, newIndex)` | 重新排序 |
| `clearPlaylist(playlistId)` | 清空歌单 |
| `setPlaylistCover(playlistId, coverBytes)` | 设置封面 |
| `removeSongFromAllPlaylists(songId)` | 从所有歌单移除指定歌曲 |
| `removeSongsFromAllPlaylists(songIds)` | 批量移除 |

---

### 2.3 LibraryFolderRepository
> 路径：`data/repositories/library_folder_repository.dart`

| 方法 | 说明 |
|------|------|
| `getAllFolders()` | 获取所有文件夹 |
| `getEnabledFolders()` | 获取启用的文件夹 |
| `getFolderById(id)` / `getFolderByPath(path)` | 按 ID/路径获取 |
| `folderExists(path)` | 检查是否已存在 |
| `addFolder(path)` | 添加新文件夹 |
| `removeFolder(id)` / `removeFolderByPath(path)` | 删除文件夹 |
| `updateScanInfo(id, scanTime, songCount)` | 更新扫描信息 |
| `toggleFolderEnabled(id)` / `setFolderEnabled(id, enabled)` | 切换启用状态 |
| `clearAllFolders()` | 清空所有文件夹 |

---

## 3. 服务层 (Services)

### 3.1 LibraryScanService
> 路径：`data/services/library_scan_service.dart`

| 方法 | 说明 |
|------|------|
| `scanFolder(folderPath, songRepository, folderRepository, onProgress?)` | 全量扫描单个文件夹 |
| `incrementalScanFolder(folderPath, songRepository, folderRepository, playlistRepository, onProgress?)` | 增量扫描（处理删除/修改） |
| `scanAllFolders(songRepository, folderRepository, playlistRepository, onProgress?, incremental?)` | 扫描所有已添加文件夹 |

**辅助类型**：
- `ScanProgress`: 扫描进度信息（phase, current, total, currentFile）
- `ScanPhase`: 扫描阶段枚举（scanning, parsing, completed）

---

### 3.2 MetadataService
> 路径：`data/services/metadata_service.dart`

| 方法 | 说明 |
|------|------|
| `readMetadata(filePath)` | 读取音频文件元数据 |
| `writeMetadata(filePath, metadata)` | 写入元数据到文件 |
| `extractCover(filePath)` | 提取封面图片 |
| `setCover(filePath, imageBytes)` | 设置封面图片 |
| `batchWriteMetadata(filePaths, metadata)` | 批量写入元数据 |

**数据模型**：
- `AudioMetadata`: 元数据对象（title, artist, album, year, coverBytes 等）

---

### 3.3 PlaylistIOService
> 路径：`data/services/playlist_io_service.dart`

| 方法 | 说明 |
|------|------|
| `exportToM3U(playlistId, outputPath, useRelativePaths?)` | 导出歌单为 M3U |
| `importFromM3U(filePath, playlistName?)` | 从 M3U 导入歌单 |
| `validateM3U(filePath)` | 验证 M3U 文件格式 |

---

## 4. 状态层 (Providers)

### 4.1 核心 Provider
> 路径：`providers/core_providers.dart`

| Provider | 类型 | 说明 |
|----------|------|------|
| `songRepositoryProvider` | `Provider<SongRepository>` | 歌曲仓库实例 |
| `playlistRepositoryProvider` | `Provider<PlaylistRepository>` | 歌单仓库实例 |
| `libraryFolderRepositoryProvider` | `Provider<LibraryFolderRepository>` | 文件夹仓库实例 |
| `libraryScanServiceProvider` | `Provider<LibraryScanService>` | 扫描服务实例 |
| `metadataServiceProvider` | `Provider<MetadataService>` | 元数据服务实例 |
| `playlistIOServiceProvider` | `Provider<PlaylistIOService>` | 歌单导入导出服务 |

---

### 4.2 导航 Provider
> 路径：`providers/navigation_provider.dart`

| Provider | 类型 | 说明 |
|----------|------|------|
| `navigationProvider` | `StateNotifierProvider<NavigationNotifier, NavRoute>` | 导航状态管理 |
| `currentViewTypeProvider` | `Provider<NavViewType>` | 当前视图类型 |
| `canGoBackProvider` | `Provider<bool>` | 是否可后退 |
| `canGoForwardProvider` | `Provider<bool>` | 是否可前进 |

**NavigationNotifier 方法**：
- `navigateTo(route)` / `navigateToView(viewType)` / `navigateToDetail(viewType, detailId)`
- `goBack()` / `goForward()` / `reset()`

---

### 4.3 歌单 Provider
> 路径：`providers/playlist_provider.dart`

| Provider | 类型 | 说明 |
|----------|------|------|
| `playlistsProvider` | `FutureProvider<List<Playlist>>` | 所有歌单列表 |
| `playlistValidSongCountProvider` | `FutureProvider.family<int, int>` | 歌单有效歌曲数 |
| `selectedPlaylistIdProvider` | `StateProvider<int?>` | 当前选中歌单 ID |
| `selectedPlaylistWithSongsProvider` | `FutureProvider<PlaylistWithSongs?>` | 选中歌单详情 |
| `playlistManagerProvider` | `StateNotifierProvider` | 歌单管理 Notifier |
| `playlistActionsProvider` | `Provider` | 便捷访问歌单操作 |

**PlaylistManagerNotifier 方法**：
- `createPlaylist(name)` / `deletePlaylist(id)` / `renamePlaylist(id, newName)`
- `addSongsToPlaylist(playlistId, songIds)` / `removeSongsFromPlaylist(...)` / `reorderSongs(...)`

---

### 4.4 扫描 Provider
> 路径：`providers/scan_provider.dart`

| Provider | 类型 | 说明 |
|----------|------|------|
| `scanProvider` | `StateNotifierProvider<ScanNotifier, ScanState>` | 扫描状态管理 |
| `isScanningProvider` | `Provider<bool>` | 是否正在扫描 |
| `scanProgressProvider` | `Provider<ScanProgress?>` | 当前扫描进度 |

**ScanNotifier 方法**：
- `scanAllFolders(incremental?)` - 扫描所有文件夹
- `scanFolder(folderPath, incremental?)` - 扫描单个文件夹
- `addFolderAndScan(folderPath)` - 添加文件夹并扫描
- `clearError()` - 清除错误状态

---

### 4.5 库刷新 Provider
> 路径：`providers/library_provider.dart`

| Provider | 说明 |
|----------|------|
| `libraryRefreshProvider` | 用于触发 UI 刷新的状态容器，调用 `.refresh()` 后所有监听它的 Provider 会重新计算 |

---

## 5. UI 组件 (Widgets)

### 5.1 通用对话框
| 组件 | 路径 | 说明 |
|------|------|------|
| `BatchEditDialog` | `ui/widgets/batch_edit_dialog.dart` | 批量编辑元数据对话框 |
| `PlaylistSelectorDialog` | `ui/widgets/playlist_selector_dialog.dart` | 歌单选择对话框（可新建歌单） |

**使用示例**：
```dart
// 批量编辑
showDialog(context: context, builder: (_) => BatchEditDialog(songs: selectedSongs));

// 添加到歌单
PlaylistSelectorDialog.show(context, songIds: [song.id]);
```

---

## 6. 视图类型 (NavViewType)

```dart
enum NavViewType {
  albums,           // 专辑视图
  artists,          // 艺术家视图
  playlists,        // 歌单视图
  folders,          // 文件夹视图
  settingsStorage,  // 存储设置
  settingsAbout,    // 关于页面
  settingsLanguage, // 语言与字体
}
```

---

## 7. 快速引用

### 获取歌曲列表
```dart
final songs = await ref.read(songRepositoryProvider).getAllSongs();
final albumSongs = await ref.read(songRepositoryProvider).getSongsByAlbum('专辑名');
```

### 添加歌曲到歌单
```dart
await ref.read(playlistRepositoryProvider).addSongsToPlaylist(playlistId, songIds);
ref.read(libraryRefreshProvider.notifier).refresh(); // 刷新 UI
```

### 触发扫描
```dart
await ref.read(scanProvider.notifier).scanAllFolders();
```

### 导航到详情页
```dart
ref.read(navigationProvider.notifier).navigateToDetail(
  NavViewType.albums,
  albumName,
  title: albumName,
);
```

### 编辑元数据
```dart
final service = ref.read(metadataServiceProvider);
await service.writeMetadata(filePath, AudioMetadata(title: '新标题'));
```
