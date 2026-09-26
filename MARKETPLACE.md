# STS3 Marketplace 등록

1. 이 저장소의 변경사항과 docs/를 main에 커밋하고 푸시합니다.
2. GitHub Settings → Pages → Deploy from a branch → main → /docs → Save를 선택합니다.
3. Pages 배포 후 STS3의 Help → Install New Software → Add에서 아래 URL로 설치하고 재시작·녹화·내보내기를 확인합니다. 기존 설치 옵션은 유지합니다.
4. Eclipse Marketplace → Add content → Add a new Solutions Listing에서 등록합니다.

| 항목 | 값 |
|---|---|
| Solution Name | Code Recorder for STS3 |
| Solution URL | https://github.com/pinnpublic/code-recorder-sts3 |
| License Type | MIT |
| Status | Beta |
| Solution Type | Requires an existing Eclipse installation |
| Support URL | https://github.com/pinnpublic/code-recorder-sts3/issues |
| Markets | Tools |
| Categories | IDE |
| Version | 0.2.6 |
| Update Site URL | https://pinnpublic.github.io/code-recorder-sts3/updates/ |
| Supported Eclipse Release | 2021-09 (4.21) |
| Platform | Windows |
| Minimum Java Version | Java 11 |
| Feature ID | dev.coderecorder.feature |
| Install state | Required |

설명:

Code Recorder for STS3 records code edits and file changes in Spring Tool Suite 3 and exports them as .coderec.json files. It captures unsaved edits, paste, code completion, undo and redo, and file switches, creation, moves and deletion.

Select a project or folder, configure excluded paths and file extensions, and start recording. Use Stop / Export to finish the recording.

This distribution targets Spring Tool Suite 3.9.18.RELEASE, based on Eclipse 4.21, on Windows with Java 11. It is packaged separately from the Eclipse and newer Spring Tools editions for its target platform.

로컬 빌드와 테스트 통과는 공개 URL의 설치 또는 마켓 승인 완료를 뜻하지 않습니다.
