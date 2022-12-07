class ConnectionUtil {
  ConnectionUtil._();

  /// throw ConnectionFailedException when timeout
  static Future<void> setTimeout(
    int timeoutSecond,
    Future future,
  ) {
    return future.timeout(
      Duration(seconds: timeoutSecond),
      onTimeout: () => throw ConnectionFailedException(),
    );
  }
}

class ConnectionFailedException implements Exception {
  @override
  String toString() => 'การเชื่อมต่อขัดข้อง กรุณาตรวจสอบอินเตอร์เนต';
}
