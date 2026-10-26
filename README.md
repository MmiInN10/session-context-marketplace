# session-context

세션이 시작될 때 현재 작업 상태를 Claude에게 자동으로 알려 주는 Claude Code `SessionStart` 훅이다.

## 훅 이름

`session-context` (이벤트: `SessionStart`)

## 훅 설명

Claude Code는 세션을 새로 시작하거나 `/clear`를 하거나 대화가 압축되면 지금 어느 브랜치에서 무엇을 고치고 있었는지 잊는다. 이 훅은 세션이 시작될 때마다 아래 정보를 모아 Claude의 맥락에 넣어, 매번 상태를 설명하지 않아도 이어서 작업할 수 있게 한다. 차단이나 파일 수정은 하지 않고 정보만 전달한다.

| 항목 | 내용 |
|------|------|
| 브랜치 | 현재 브랜치. `main`/`master`이면 "큰 변경 전에 브랜치를 만드세요" 경고 |
| 변경 파일 | `git status` 요약 (최대 8개, 나머지는 개수만) |
| 최근 커밋 | 최근 3개 |
| Python | 버전, 가상환경 활성 여부 (가상환경은 폴더명만 출력해 경로의 사용자 이름이 노출되지 않음) |

Git 저장소가 아니거나 Python이 없는 폴더에서는 해당 항목만 건너뛰고 오류 없이 종료한다.

## 훅 설치 명령어

Claude Code에서 아래 두 줄을 차례로 입력한다.

```
/plugin marketplace add MmiInN10/session-context-marketplace
/plugin install session-context@session-context-marketplace
```

설치 후 `/reload-plugins`를 입력하거나 새 세션을 시작한다. 요구 사항은 Windows, PowerShell, Git이다.

## 훅 사용 예시

설치 후에는 따로 호출하지 않아도 세션이 시작될 때마다 자동으로 실행된다. 아래는 Claude에게 전달되는 내용의 예시다.

```
[세션 시작 상태]
브랜치: feature/train-yolo
변경 파일: 3개
  M train.py
  M data.yaml
  ?? notes.md
최근 커밋:
  3b75f1d 학습 스크립트 추가
  393e122 gitignore설정
  20686ec 데이터셋 정리
Python: Python 3.8.5
가상환경: 비활성 (.venv 폴더가 있으니 활성화 후 pip를 쓰세요)
```

이 상태에서 "방금 하던 거 이어서 해줘"라고만 말해도 Claude가 `train.py`와 `data.yaml`부터 확인한다. `main`에서 시작하면 "기본 브랜치입니다" 경고가 함께 전달되고, 가상환경이 꺼져 있으면 시스템 Python에 패키지를 설치하는 실수를 줄일 수 있다.

## 파일 구성

```
.claude-plugin/marketplace.json
plugins/session-context/
├── .claude-plugin/plugin.json
└── hooks/
    ├── hooks.json
    └── session-context.ps1
```
