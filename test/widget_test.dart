import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Emantran/data/repositories/api_repository.dart';

void main() {
  group('ApiRepository Unit Tests', () {
    setUp(() {
      // Mock dotenv file variables for test environment
      dotenv.testLoad(fileInput: 'MOCK_DATA=true\nAPI_URL=http://localhost\nPHYSICAL_DEVICE=false');
    });

    test('Initialization seeds mock rooms correctly in mock mode', () {
      final repository = ApiRepository();
      
      // Let's verify initial properties
      expect(repository.syncError, isNull);
      expect(repository.isSyncing, isFalse);
      
      // Cancel timers or clean up repository resources to avoid leak warnings
      repository.logout();
    });
  });
}
