import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/repositories.dart';
import '../data/services/services.dart';

// ==================== Repository Providers ====================

/// SongRepository Provider
final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository();
});

/// PlaylistRepository Provider
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository();
});

/// LibraryFolderRepository Provider
final libraryFolderRepositoryProvider = Provider<LibraryFolderRepository>((
  ref,
) {
  return LibraryFolderRepository();
});

// ==================== Service Providers ====================

/// LibraryScanService Provider
final libraryScanServiceProvider = Provider<LibraryScanService>((ref) {
  return LibraryScanService();
});

/// MetadataService Provider
final metadataServiceProvider = Provider<MetadataService>((ref) {
  return MetadataService();
});

/// PlaylistIOService Provider
final playlistIOServiceProvider = Provider<PlaylistIOService>((ref) {
  return PlaylistIOService(
    songRepository: ref.watch(songRepositoryProvider),
    playlistRepository: ref.watch(playlistRepositoryProvider),
  );
});
