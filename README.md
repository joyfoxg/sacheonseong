# 사천성 게임 (Sacheonseong Game)

Flutter로 개발된 스탠드얼론 사천성 게임 프로젝트입니다.

## 주요 기능

*   **사천성 게임 로직**: 표준 사천성 규칙(두 번 이하의 꺾임으로 연결)을 따르는 게임 플레이.
*   **타이틀 화면**: 직관적인 시작 화면과 배경 이미지.
*   **오디오 시스템**:
    *   배경음악 (BGM): 타이틀 및 게임 플레이 중 연속 재생.
    *   효과음: 패 선택, 매칭 성공, 매칭 실패 시 반응형 사운드 제공.
*   **힌트 및 섞기**: 게임 진행이 어려울 때 사용할 수 있는 아이템 기능.

## 프로젝트 구조

*   `bgm.mp3`: 배경 음악
*   `lib/main.dart`: 앱의 진입점.
*   `lib/title_screen.dart`: 타이틀 화면. 배경 이미지와 게임 시작 기능을 담당.
*   `lib/game_screen.dart`: 실제 게임 플레이 화면 및 UI.
*   `lib/game_logic.dart`: 사천성 알고리즘 (경로 탐색, 맵 생성 등) 핵심 로직.
*   `lib/audio_manager.dart`: 배경음악 및 효과음 재생을 관리하는 Singleton 클래스.
*   `assets/image/`: 게임에 사용되는 이미지 리소스 (타이틀, 아이콘 등).
*   `assets/audio/`: 게임에 사용되는 오디오 리소스.

## 시작하기 (Getting Started)

이 프로젝트는 Flutter 프레임워크를 사용합니다.

### 전제 조건

*   Flutter SDK가 설치되어 있어야 합니다.
*   Android Studio 또는 VS Code와 같은 Flutter 개발 환경이 구성되어 있어야 합니다.

### 실행 방법

1.  의존성 패키지를 설치합니다.
    ```bash
    flutter pub get
    ```

2.  앱을 실행합니다.
    ```bash
    flutter run
    ```

### 에셋 및 아이콘

*   **아이콘 변경**: `assets/image/icon.png`를 교체한 후 아래 명령어를 실행하여 앱 아이콘을 갱신할 수 있습니다.
    ```bash
    dart run flutter_launcher_icons
    ```
*   **오디오 파일**: `assets/audio/` 폴더에 `bgm.mp3`, `select.mp3`, `sucess.mp3`, `fail.mp3` 파일이 위치해야 합니다.

## 라이선스

이 프로젝트는 개인 학습 및 포트폴리오 목적으로 제작되었습니다.
