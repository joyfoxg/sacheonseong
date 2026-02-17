import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sacheonseong_game/game_logic.dart';

void main() {
  test('Check for missing tile assets', () async {
    // 윈도우 경로 구분자 고려, 하지만 Dart io는 / 처리 잘 함
    // 프로젝트 루트에서 실행되므로 assets/image/tiles 경로 확인
    final assetDir = Directory('assets/image/tiles');
    if (!assetDir.existsSync()) {
      print('Asset directory not found at ${assetDir.path}');
      // test 실행 위치가 다를 수 있음. 절대 경로 시도?
      // 일단 실패 처리
      fail('Asset directory not found');
    }
    
    // 파일 목록 로드
    final existingFiles = assetDir.listSync().whereType<File>().map((e) => e.uri.pathSegments.last).toSet();
    
    final definedFiles = SichuanLogic.allTileFiles;
    
    List<String> missing = [];
    for (var file in definedFiles) {
      if (!existingFiles.contains(file)) {
        missing.add(file);
      }
    }
    
    if (missing.isNotEmpty) {
      print('MISSING_FILES_START');
      for (var f in missing) {
        print(f);
      }
      print('MISSING_FILES_END');
      fail('Found ${missing.length} missing asset files');
    } else {
      print('All ${definedFiles.length} assets exist.');
    }
  });
}
