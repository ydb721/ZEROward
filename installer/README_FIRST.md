# ZEROward Windows 설치용 시제품 킷

## 중요한 구분

이 ZIP 자체는 `ZEROward-Setup.exe`가 **아닙니다**. 최신 ZEROward 프로젝트의 소스를 현재 대화에서 받지 못해 **실제 실행·설치 테스트는 하지 않았습니다**. 이 킷은 사용자의 Windows PC에서 `on-client` 코드를 설치 프로그램으로 만드는 *초안 빌드 도구*입니다. 최종 제출·배포 전에는 실제 소스에 맞춰 검증하세요.

- **시제품 방식**: Inno Setup 설치 마법사 → 로컬 Node.js 서버를 시작 → 기본 브라우저에서 ZEROward 열기. 설치/시작 메뉴/바탕화면 선택/제거 기능을 제공합니다.
- **독립 네이티브 창(Electron/WebView2)**은 **아직 아닙니다**. 이 방식으로는 사용자가 브라우저를 보게 됩니다.
- ALEPH 과제 원본/원격 저장소/Git을 수정하지 않습니다.
- Microsoft Defender, Windows 보안 등 읽기 전용 조회는 원본 앱 구현과 OS 권한을 따릅니다. 설치 성공이 모든 진단의 성공을 보장하지 않습니다.

## 지금 가장 빠른 정확한 경로

`Export-ZEROward-Source.ps1`을 실행해 만든 ZIP을 ChatGPT 대화에 첨부하면, 현재 코드를 근거로 Electron 등 진짜 독립 창이나 이 빌드 도구의 정확한 수정 사항을 검토할 수 있습니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Export-ZEROward-Source.ps1
```

생성 위치: 바탕화면 `ZEROward-source-review-날짜시간.zip`. **업로드 전에 ZIP 내부에서 비밀번호, 토큰, 비밀키, 개인 자료가 없는지 반드시 확인하세요.** 파일명에 의한 자동 제외는 완전한 비밀정보 탐지 방법이 아닙니다.

## 브라우저 기반 설치용 시제품을 직접 빌드하는 방법

1. Windows PC에 Node.js가 설치되어 있는지 확인합니다 (현재 사용자는 `C:\Program Files\nodejs\node.exe`).
2. 공식 사이트 https://jrsoftware.org/isinfo.php 에서 Inno Setup 6/7을 설치합니다.
3. 이 ZIP을 프로젝트 **외부 별도 폴더**에 풉니다.
4. PowerShell에서 그 폴더로 이동하고 다음을 실행합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Build-ZEROward.ps1
```

5. 컴파일이 완료되면 같은 폴더 안 `output\ZEROward-Setup.exe`가 생성되고 SHA-256 해시가 표시됩니다.
6. 설치 → 시작 메뉴 실행 → `mode: local` 확인 → PC/Windows/Defender 조회 → 종료 → 제거까지 테스트합니다.

## 중요 주의

- 코드가 `127.0.0.1`에만 바인딩되어 있는지 반드시 확인하세요. `0.0.0.0` 또는 외부 인터페이스에 공개되지 않아야 합니다.
- 고정 포트 5189가 다른 프로그램에 의해 점유되면 실행이 중단되도록 만들었습니다. **다른 프로세스를 강제 종료하지 않습니다.**
- 설치를 위해 `ExecutionPolicy Bypass`를 적용하는 것은 PowerShell 스크립트 실행에만 한정되어 있으며 Defender/방화벽/업데이트 기능을 비활성화하지 않습니다.
- 스크립트는 `.env`, 인증키·토큰 등 흔한 비밀정보 파일을 제외하지만 모든 비밀이 제거되었는지 보장하지 않습니다. 공개 배포 전 소스·설정·저장된 데이터를 수동 검토하세요.
- 프로그램 창을 닫아도 Node 서버 프로세스는 유지됩니다. 시작 메뉴의 `ZEROward 종료`로 중지할 수 있습니다. 이 점은 정식 배포형 앱으로 개선해야 합니다.
- Inno Setup과 Node 바이너리 등 서드파티 소프트웨어 라이선스 및 원본 ALEPH 코드의 재배포 권한을 확인해야 합니다.
- 서명 없는 설치 파일은 SmartScreen/백신의 경고 또는 제한 대상이 될 수 있습니다. 보안 기능을 끄거나 우회하지 마세요.
- 타인의 PC에서 작동하는 정식 제품으로 배포하기 전에, 실제 소스 구조 및 필요한 Native Host/계정 연동/외부 런타임 의존성을 점검해야 합니다.

## 빌드 중 실패 시

오류 전체를 ChatGPT에 전달하세요. 비밀키와 계정정보는 지우고 전송하세요. 이 킷은 최신 소스가 없어서 실제 Windows 컴파일/실행 검증이 아직 되지 않았습니다.
