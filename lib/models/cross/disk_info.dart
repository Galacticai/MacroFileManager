class PartitionInfo {
  const PartitionInfo({
    required this.devicePath,
    required this.label,
    required this.uuidPartition,
    required this.uuidDisk,
    required this.fileSystem,
    required this.blockSize,
    required this.totalSize,
    required this.usedSpace,
  });

  /// path of this partition
  /// e.g. /dev/sda1
  final String devicePath;

  /// label of this partition
  final String label;

  /// uuid of this partition
  final String uuidPartition;

  /// uuid of the disk that contains this partition
  final String uuidDisk;

  /// ext4, ntfs, fat32, ...
  final String fileSystem;

  /// size of a block in bytes
  final int blockSize;

  /// total size of this partition in bytes
  final int totalSize;

  /// used space in bytes
  final int usedSpace;

  /// available space in bytes
  int get availableSpace => totalSize - usedSpace;

  /// ratio of used space to total size
  double get usedRatio => usedSpace / totalSize;

  static Future<PartitionInfo> getWindows() async {
    final devicePath = 'C:';
    final label = 'Windows';
    final uuidPartition = '';
    final uuidDisk = '';
    final fileSystem = 'ntfs';
    final blockSize = 4096;
    final totalSize = 100000000000;
    final usedSpace = 50000000000;

    return PartitionInfo(
      devicePath: devicePath,
      label: label,
      uuidPartition: uuidPartition,
      uuidDisk: uuidDisk,
      fileSystem: fileSystem,
      blockSize: blockSize,
      totalSize: totalSize,
      usedSpace: usedSpace,
    );
  }
}
