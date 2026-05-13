# 팀 Claude Code 온보딩 가이드

## 목적

팀원 누구의 머신에서 Claude Code 를 실행해도 **같은 코딩 컨벤션·같은 응답 스타일·같은 워크플로우**가 적용되도록 한다.
이 문서는 새 팀원이 합류했을 때 처음부터 끝까지 따라갈 수 있는 절차서다.

---

## 0. 핵심 아이디어

Claude Code 는 세션 시작 시 저장소에 커밋된 다음 파일들을 **자동으로 로드**한다.

| 파일                          | 역할                                             | 공유 여부     |
| ----------------------------- | ------------------------------------------------ | ------------- |
| `CLAUDE.md`                   | 프로젝트 규칙·컨벤션 (모든 세션 컨텍스트에 주입) | git 커밋      |
| `.claude/settings.json`       | 권한·훅·환경변수                                 | git 커밋      |
| `.claude/commands/*.md`       | 팀 공통 슬래시 명령                              | git 커밋      |
| `.claude/skills/*`            | 팀 공통 워크플로우 스킬                          | git 커밋      |
| `.claude/settings.local.json` | 개인 설정 (API 키, 로컬 경로)                    | **gitignore** |

> 팀 컨벤션은 **git 으로** 관리하고, **개인 취향만 local 로** 분리한다.

---

## 1. 사전 준비 (새 팀원 1회)

1. Claude Code 설치 및 로그인 (`claude` CLI 또는 IDE 확장).
2. 저장소 clone.
3. Python 3.x + 가상환경 도구(venv / uv / poetry — 팀이 합의한 것).
4. `git config user.name`, `git config user.email` 확인.

---

## 2. 저장소에 추가할 파일들

### 2.1 `CLAUDE.md` (프로젝트 루트)

> 200줄 이내로 유지. 모든 세션 토큰을 차지하므로 짧고 정확하게.

````markdown
# 프로젝트 컨벤션

## 프로젝트 개요

- 무엇을 만드는가, 누가 쓰는가 (한 단락)

## Python 코딩 규칙

- 포맷터/린터: Ruff (설정은 `pyproject.toml` 참조)
- 타입 힌트: 모든 public 함수 필수, `from __future__ import annotations`
- Docstring: Google 스타일
- 네이밍: snake_case (함수/변수), PascalCase (클래스), UPPER_SNAKE (상수)
- 예외: 광범위한 `except Exception` 금지, 구체 타입만 catch
- 로깅: `logging` 모듈만 사용, print 금지

## Claude 동작 규칙

- 응답 언어: 한국어
- 테스트 우선(TDD): 새 기능은 pytest 케이스 먼저 작성 후 구현
- Surgical changes: 요청 범위 밖 코드는 수정하지 않는다
- 위험 명령 실행 전 확인 필수: rm -rf, git push --force, db drop 등
- 커밋: Conventional Commits (feat:, fix:, refactor:, docs:, test:)
- 한 PR 한 주제

## 자주 쓰는 명령

```bash
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
pytest -xvs
ruff check . && ruff format .
```
````

## PR 전 체크리스트

- [ ] ruff check 통과
- [ ] pytest 전부 green
- [ ] 변경 범위 PR 설명에 명시

````

### 2.2 `pyproject.toml` (single source of truth)

Ruff, pytest, mypy 설정은 여기 한 곳에. CLAUDE.md 는 **참조만** 한다.
사람·CI·Claude 가 같은 규칙을 봐야 일관성이 깨지지 않는다.

### 2.3 `.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(pytest:*)",
      "Bash(ruff:*)",
      "Bash(python -m:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)"
    ]
  }
}
````

자주 쓰는 안전한 명령은 권한 프롬프트 없이 실행되어 흐름이 끊기지 않는다.

### 2.4 `.claude/settings.local.json` (gitignore 대상)

개인용. 템플릿(`settings.local.example.json`)만 커밋하고 실제 파일은 ignore.

### 2.5 `.claude/commands/` (팀 공통 슬래시 명령)

자주 반복되는 절차를 명령화한다.

**`.claude/commands/test.md`**

```markdown
---
description: 표준 옵션으로 pytest 실행
allowed-tools: Bash(pytest:*)
---

`pytest -xvs --tb=short` 를 실행하고, 실패가 있으면 첫 실패 원인을 한 단락으로 요약해.
```

**`.claude/commands/review.md`**

```markdown
---
description: PR 올리기 전 self-review
---

1. `git diff origin/main...HEAD` 로 전체 변경 확인
2. ruff check, pytest 실행
3. 변경된 코드에서 CLAUDE.md 컨벤션 위반이 있는지 점검
4. 발견된 이슈와 PR 요약 출력
```

**`.claude/commands/kickoff-log.md`** — 이미 글로벌에 있다면 그대로 사용.

### 2.6 `.gitignore`

```
.venv/
__pycache__/
*.pyc
.pytest_cache/
.ruff_cache/

# Claude
.claude/settings.local.json
```

---

## 3. 첫 세션 워크스루 (새 팀원)

1. `cd <project> && claude`
2. 세션 시작 후 임의 질문으로 응답 확인 — **한국어로 응답**하는지, 컨벤션을 인지하는지 검증.
3. 일부러 컨벤션 위반 요청을 해본다: "타입 힌트 없이 함수 작성해줘" → Claude 가 거절하거나 교정 제안하면 OK.
4. `/test`, `/review` 슬래시 명령이 동작하는지 호출.

---

## 4. 운영 원칙

- **CLAUDE.md 변경은 반드시 PR 로** — git blame 으로 추적 가능해야 한다.
- **분기마다 정리** — 한 번도 발동하지 않거나 항상 무시되는 규칙은 제거. 짧은 컨벤션이 잘 지켜진다.
- **개인 취향과 팀 규칙 분리** — 개인 선호는 `~/.claude/CLAUDE.md` (글로벌) 또는 `settings.local.json`. 프로젝트 `CLAUDE.md` 에는 **합의된 것만**.
- **실험은 브랜치에서** — 새 hook, 새 슬래시 명령은 별도 브랜치에서 시험 후 머지.
- **충돌 시 우선순위**: 사용자 명시적 지시 > 프로젝트 CLAUDE.md > 글로벌 CLAUDE.md > Claude 기본 동작.

---

## 5. 자주 빠지는 함정

| 함정                                           | 대응                                                          |
| ---------------------------------------------- | ------------------------------------------------------------- |
| CLAUDE.md 가 점점 길어져 컨벤션이 묻힘         | 200줄 cap, 분기 정리, 일반 상식은 빼기                        |
| 사람마다 ruff 설정이 달라짐                    | `pyproject.toml` 만이 진실, 에디터 설정은 거기서 읽도록       |
| `.claude/settings.local.json` 이 실수로 커밋됨 | `.gitignore` 에 먼저 추가, 템플릿만 커밋                      |
| 슬래시 명령이 분산됨                           | 글로벌이 아닌 **프로젝트 `.claude/commands`** 에 둬야 팀 공유 |
| 신규 인원이 온보딩 문서를 못 찾음              | README 상단에 이 문서 링크 명시                               |

---

## 6. 체크리스트 (셋업 완료 기준)

- [ ] 루트에 `CLAUDE.md` 존재 & 팀 합의된 규칙만 포함
- [ ] `pyproject.toml` 에 Ruff·pytest 설정 통일
- [ ] `.claude/settings.json` 커밋, `.claude/settings.local.json` 은 gitignore
- [ ] `.claude/commands/` 에 `/test`, `/review` 최소 2개 명령 존재
- [ ] `.gitignore` 에 `.venv`, `__pycache__`, `.claude/settings.local.json` 포함
- [ ] README 에 본 온보딩 문서 링크
- [ ] 새 팀원 한 명이 fresh clone → 첫 세션까지 막힘없이 도달
