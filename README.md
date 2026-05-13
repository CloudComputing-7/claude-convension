# 팀 Claude Code 온보딩 가이드

## 목적

팀원 누구의 머신에서 Claude Code 를 실행해도 **같은 코딩 컨벤션·같은 응답 스타일·같은 워크플로우**가 적용되도록 한다.
이 문서는 새 팀원이 합류했을 때 처음부터 끝까지 따라갈 수 있는 절차서다.

> 본 가이드는 **언어/스택 중립**이다. 본문은 `<포맷터>`, `<테스트 러너>` 같은 플레이스홀더로 쓰고, 각 섹션 끝의 접이식 예시 박스에서 Python / TypeScript / Go 구체 사례를 보여준다.

---

## 0. 핵심 아이디어

Claude Code 는 세션 시작 시 저장소에 커밋된 다음 파일들을 **자동으로 로드**한다.

| 파일                          | 역할                                             | 공유 여부     |
| ----------------------------- | ------------------------------------------------ | ------------- |
| `CLAUDE.md`                   | 프로젝트 규칙·컨벤션 (모든 세션 컨텍스트에 주입) | git 커밋      |
| `.claude/settings.json`       | 권한·훅·환경변수                                 | git 커밋      |
| `.claude/commands/*.md`       | 팀 공통 슬래시 명령                              | git 커밋      |
| `.claude/agents/*.md`         | 팀 공통 서브에이전트                             | git 커밋      |
| `.claude/skills/*`            | 팀 공통 워크플로우 스킬                          | git 커밋      |
| `.mcp.json`                   | 팀 공통 MCP 서버 설정                            | git 커밋      |
| `.claude/settings.local.json` | 개인 설정 (API 키, 로컬 경로)                    | **gitignore** |

> 팀 컨벤션은 **git 으로** 관리하고, **개인 취향·자격증명만 local 로** 분리한다.

---

## 1. 사전 준비 (새 팀원 1회)

1. Claude Code 설치 및 로그인 (`claude` CLI 또는 IDE 확장).
2. 저장소 clone.
3. 프로젝트 언어의 **표준 빌드/런타임 도구** 설치 (팀이 합의한 버전).
4. `git config user.name`, `git config user.email` 확인.

<details>
<summary>예시: Python / TypeScript / Go</summary>

- Python: Python 3.x + 가상환경 도구(venv / uv / poetry)
- TypeScript: Node LTS + 패키지 매니저(pnpm / npm / yarn)
- Go: Go 1.x + `go mod`
</details>

---

## 2. 저장소에 추가할 파일들

### 2.1 `CLAUDE.md` (프로젝트 루트)

> 200줄 이내로 유지. 모든 세션 토큰을 차지하므로 짧고 정확하게.

````markdown
# 프로젝트 컨벤션

## 프로젝트 개요

- 무엇을 만드는가, 누가 쓰는가 (한 단락)

## <언어> 코딩 규칙

- 포맷터/린터: `<포맷터·린터>` (설정은 `<설정 통합 파일>` 참조)
- 타입 체크: `<타입 체커>` — 모든 public API 에 타입 명시
- 문서화: `<docstring/주석 스타일>`
- 네이밍: 프로젝트 언어의 표준 컨벤션을 따른다
- 예외 처리: 광범위한 catch-all 금지, 구체 타입만 잡는다
- 로깅: 표준 로거만 사용, 디버그 출력문 금지

## Claude 동작 규칙

- 응답 언어: 한국어
- 테스트 우선(TDD): 새 기능은 테스트 먼저 작성 후 구현
- Surgical changes: 요청 범위 밖 코드는 수정하지 않는다
- 위험 명령 실행 전 확인 필수: `rm -rf`, `git push --force`, DB drop 등
- 커밋: Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`)
- 한 PR 한 주제

## 자주 쓰는 명령

```bash
<setup_command>      # 의존성 설치 / 환경 준비
<test_command>       # 테스트 실행
<lint_command>       # 포맷·린트
```

## PR 전 체크리스트

- [ ] 린트 통과
- [ ] 테스트 전부 green
- [ ] 변경 범위 PR 설명에 명시
````

<details>
<summary>예시: Python / TypeScript / Go</summary>

| 항목      | Python                    | TypeScript                       | Go                        |
| --------- | ------------------------- | -------------------------------- | ------------------------- |
| 포맷·린트 | Ruff                      | Biome (또는 ESLint + Prettier)   | `gofmt` / `golangci-lint` |
| 테스트    | pytest                    | Vitest / Jest                    | `go test`                 |
| 타입      | mypy / pyright            | tsc                              | (내장)                    |
| 설정 파일 | `pyproject.toml`          | `package.json` / `tsconfig.json` | `go.mod`                  |
| setup     | `pip install -e ".[dev]"` | `pnpm install`                   | `go mod download`         |

</details>

### 2.2 설정 통합 파일 (single source of truth)

린트·테스트·타입 체크 설정은 **언어 표준 설정 파일 한 곳**에 둔다. `CLAUDE.md` 는 **참조만** 한다.
사람·CI·Claude 가 같은 규칙을 봐야 일관성이 깨지지 않는다.

<details>
<summary>예시: 어느 파일에 두는가</summary>

- Python: `pyproject.toml` (`[tool.ruff]`, `[tool.pytest.ini_options]`, `[tool.mypy]`)
- TypeScript: `package.json` + `tsconfig.json` + `biome.json`
- Go: `go.mod` + `.golangci.yml`
</details>

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
      "Bash(<test_command>:*)",
      "Bash(<lint_command>:*)"
    ],
    "deny": ["Bash(rm -rf:*)", "Bash(git push --force:*)"]
  }
}
```

자주 쓰는 안전한 명령은 권한 프롬프트 없이 실행되어 흐름이 끊기지 않는다.

<details>
<summary>예시: 언어별 allow 엔트리</summary>

- Python: `Bash(pytest:*)`, `Bash(ruff:*)`, `Bash(python -m:*)`
- TypeScript: `Bash(pnpm test:*)`, `Bash(biome:*)`, `Bash(tsc:*)`
- Go: `Bash(go test:*)`, `Bash(go build:*)`, `Bash(golangci-lint:*)`
</details>

### 2.4 `.claude/settings.local.json` (gitignore 대상)

개인용. 템플릿(`settings.local.example.json`)만 커밋하고 실제 파일은 ignore.

### 2.5 `.claude/commands/` (팀 공통 슬래시 명령)

자주 반복되는 절차를 명령화한다.

**`.claude/commands/test.md`**

```markdown
---
description: 표준 옵션으로 테스트 실행
allowed-tools: Bash(<test_command>:*)
---

`<test_command>` 를 실행하고, 실패가 있으면 첫 실패 원인을 한 단락으로 요약해.
```

**`.claude/commands/review.md`**

```markdown
---
description: PR 올리기 전 self-review
---

1. `git diff origin/main...HEAD` 로 전체 변경 확인
2. `<lint_command>`, `<test_command>` 실행
3. 변경된 코드에서 CLAUDE.md 컨벤션 위반이 있는지 점검
4. 발견된 이슈와 PR 요약 출력
```

<details>
<summary>예시: 플레이스홀더 치환</summary>

| 플레이스홀더     | Python                          | TypeScript  | Go                  |
| ---------------- | ------------------------------- | ----------- | ------------------- |
| `<test_command>` | `pytest -xvs --tb=short`        | `pnpm test` | `go test ./...`     |
| `<lint_command>` | `ruff check . && ruff format .` | `pnpm lint` | `golangci-lint run` |

</details>

### 2.6 `.gitignore`

언어별 빌드/캐시 산출물 + Claude 개인 설정을 ignore.

```
# Claude
.claude/settings.local.json

# 언어별 빌드/캐시 산출물 — 아래 예시 박스 참고
```

<details>
<summary>예시: 언어별 ignore 항목</summary>

- Python: `.venv/`, `__pycache__/`, `*.pyc`, `.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/`
- TypeScript: `node_modules/`, `dist/`, `.next/`, `coverage/`, `*.tsbuildinfo`
- Go: `bin/`, `vendor/`, `*.test`, `coverage.out`
</details>

### 2.7 `.claude/settings.json` 의 hooks — 자동화 강제

사람이 잊어도 컨벤션이 지켜지도록 hooks 로 자동화한다.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/block-dangerous.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/format-changed.sh" }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          { "type": "command", "command": ".claude/hooks/warn-secrets.sh" }
        ]
      }
    ]
  }
}
```

권장 시나리오:

- **PreToolUse / Bash** — `rm -rf`, `git push --force`, DB drop 등을 정규식으로 차단 (스크립트가 exit code 2 로 종료하면 도구 호출이 거부됨).
- **PostToolUse / Edit·Write** — 변경된 파일 경로를 받아 포맷터를 자동 실행.
- **UserPromptSubmit** — 프롬프트에 `.env`, `*.pem`, `id_rsa` 같은 시크릿 경로가 보이면 경고.

> hooks 는 **사용자 머신에서 임의 셸을 실행**한다. 새 hook 추가·수정은 반드시 PR 리뷰를 거치고, 스크립트도 같은 저장소에 커밋해 git blame 으로 추적되게 한다.

### 2.8 `.claude/agents/` — 팀 공통 서브에이전트

반복 작업을 도메인 전문 서브에이전트로 캡슐화한다. 각 파일은 frontmatter + 시스템 프롬프트 한 덩어리다.

```markdown
---
name: code-reviewer
description: 변경 diff 만 받아 CLAUDE.md 컨벤션 위반을 점검
tools: Bash, Read, Grep
---

당신은 코드 리뷰어다. `git diff` 출력을 입력으로 받고,
CLAUDE.md 규칙(네이밍·예외 처리·로깅·테스트 누락)을 항목별로 점검해 표로 출력한다.
```

권장 셋:

- `code-reviewer` — diff 컨벤션 점검
- `test-writer` — 함수 시그니처 → 테스트 케이스
- `migration-checker` — DB/스키마 변경 안전성 검토

### 2.9 `.mcp.json` — 팀 MCP 서버 공유

모든 팀원이 같은 MCP 서버(Context7, 사내 도구 등)에 자동 연결되도록 루트에 `.mcp.json` 을 커밋한다.

```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    },
    "internal-docs": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@org/internal-docs-mcp"],
      "env": {
        "ORG_API_TOKEN": "${ORG_API_TOKEN}"
      }
    }
  }
}
```

> 자격증명은 `.mcp.json` 에 **평문으로 넣지 않는다**. `${ENV_VAR}` 형태로 참조하고, 실제 값은 개인 셸 환경이나 `.claude/settings.local.json` 에 둔다.

---

## 3. 첫 세션 워크스루 (새 팀원)

1. `cd <project> && claude`
2. 세션 시작 후 임의 질문으로 응답 확인 — **한국어로 응답**하는지, 컨벤션을 인지하는지 검증.
3. 일부러 컨벤션 위반 요청을 해본다: "타입 없이 함수 작성해줘" → Claude 가 거절하거나 교정 제안하면 OK.
4. `/test`, `/review`, `/onboarding-check` 슬래시 명령이 동작하는지 호출.

### 3.1 `/onboarding-check` — 셋업 자가 검증

새 팀원이 셋업을 스스로 검증할 수 있게 슬래시 명령 하나를 둔다.

**`.claude/commands/onboarding-check.md`**

```markdown
---
description: 온보딩 셋업이 끝났는지 자가 점검
---

다음 항목을 점검해 표(✅/❌)로 출력하고, 실패 항목은 한 줄 해결 방법을 제시해.

1. 루트에 `CLAUDE.md` 가 있고 200줄 이하인가
2. `.claude/settings.json` 이 존재하는가
3. `.gitignore` 에 `.claude/settings.local.json` 이 포함되어 있는가
4. `.claude/commands/` 에 `test.md`, `review.md` 가 있는가
5. `.mcp.json` 이 있다면 자격증명이 평문으로 들어있지 않은가
6. 응답 언어가 한국어인가 (이 답변 자체로 확인)
```

---

## 4. 운영 원칙

- **CLAUDE.md 변경은 반드시 PR 로** — git blame 으로 추적 가능해야 한다.
- **분기마다 정리** — 한 번도 발동하지 않거나 항상 무시되는 규칙은 제거. 짧은 컨벤션이 잘 지켜진다.
- **개인 취향과 팀 규칙 분리** — 개인 선호는 `~/.claude/CLAUDE.md` (글로벌) 또는 `settings.local.json`. 프로젝트 `CLAUDE.md` 에는 **합의된 것만**.
- **실험은 브랜치에서** — 새 hook, 새 슬래시 명령, 새 서브에이전트는 별도 브랜치에서 시험 후 머지.
- **충돌 시 우선순위**: 사용자 명시적 지시 > 프로젝트 `CLAUDE.md` > 글로벌 `CLAUDE.md` > Claude 기본 동작.

---

## 5. 자주 빠지는 함정

| 함정                                            | 대응                                                          |
| ----------------------------------------------- | ------------------------------------------------------------- |
| `CLAUDE.md` 가 점점 길어져 컨벤션이 묻힘        | 200줄 cap, 분기 정리, 일반 상식은 빼기                        |
| 사람마다 린트 설정이 달라짐                     | 언어 표준 설정 파일만이 진실, 에디터 설정은 거기서 읽도록     |
| `.claude/settings.local.json` 이 실수로 커밋됨  | `.gitignore` 에 먼저 추가, 템플릿만 커밋                      |
| 슬래시 명령·서브에이전트가 개인 글로벌에 흩어짐 | **프로젝트 `.claude/`** 에 둬야 팀 공유                       |
| hook 이 무한 루프·심각한 지연을 만듦            | 스크립트는 빠르게 실패, 출력은 짧게. 변경 시 다른 팀원이 리뷰 |
| `.mcp.json` 에 토큰을 평문으로 커밋             | `${ENV_VAR}` 참조로 분리, 실제 값은 로컬 환경에만             |
| 신규 인원이 온보딩 문서를 못 찾음               | README 상단에 이 문서 링크 명시                               |

---

## 6. 체크리스트 (셋업 완료 기준)

**필수**

- [ ] 루트에 `CLAUDE.md` 존재 & 팀 합의된 규칙만 포함
- [ ] 언어 표준 설정 파일에 린트·테스트 설정 통일
- [ ] `.claude/settings.json` 커밋, `.claude/settings.local.json` 은 gitignore
- [ ] `.claude/commands/` 에 `/test`, `/review` 최소 2개 명령 존재
- [ ] `.gitignore` 에 언어별 산출물 + `.claude/settings.local.json` 포함
- [ ] README 에 본 온보딩 문서 링크
- [ ] 새 팀원 한 명이 fresh clone → 첫 세션까지 막힘없이 도달

**선택 (팀 성숙도에 따라 추가)**

- [ ] `.claude/settings.json` 의 hooks 로 위험 명령 차단·자동 포맷
- [ ] `.claude/agents/` 에 팀 공통 서브에이전트(code-reviewer 등) 1개 이상
- [ ] `.mcp.json` 으로 팀 MCP 서버 공유 (자격증명은 env 참조)
- [ ] `/onboarding-check` 슬래시 명령으로 셋업 자가 검증

---

## 7. 이 저장소가 제공하는 것 (Quick Start)

위 §2 가 "어떤 파일을 둬야 하는가"라면, 이 섹션은 **이 저장소에 이미 포함된 실제 파일**과 **본인 프로젝트로 옮기는 절차**다.

### 7.1 포함된 파일 인벤토리

| 경로                                              | 역할                                                                  |
| ------------------------------------------------- | --------------------------------------------------------------------- |
| `CLAUDE.md`                                       | 프로젝트 규약 템플릿 (`<...>` 플레이스홀더 포함)                      |
| `.gitignore`                                      | `.claude/settings.local.json` 제외 + 언어별 가이드 주석               |
| `.claude/settings.json`                           | 권한 allow/deny + 3종 hook 와이어링                                   |
| `.claude/settings.local.example.json`             | 개인 환경변수 템플릿 (실제 파일은 gitignore)                          |
| `.claude/commands/haruboan/init-project.md`       | **스택 감지 → 플레이스홀더 일괄 치환**                                |
| `.claude/commands/haruboan/onboarding-check.md`   | 셋업 자가 점검                                                        |
| `.claude/commands/haruboan/test.md` · `review.md` | 테스트 실행 / PR 전 self-review                                       |
| `.claude/agents/haruboan/code-reviewer.md`        | diff 만 받아 CLAUDE.md 위반 점검                                      |
| `.claude/agents/haruboan/migration-checker.md`    | DB/스키마 변경 안전성 검토                                            |
| `.claude/agents/haruboan/test-writer.md`          | 시그니처 → 테스트 케이스 (TDD red)                                    |
| `.claude/skills/haruboan-commit/SKILL.md`         | 스테이징된 변경 → Conventional Commit                                 |
| `.claude/skills/haruboan-pr-prep/SKILL.md`        | 변경 범위 → 린트 → 테스트 → 컨벤션 → PR 본문                          |
| `.claude/hooks/block-dangerous.sh`                | 위험 셸 명령 차단 (PreToolUse) — **TODO 패턴 미작성**                 |
| `.claude/hooks/format-changed.sh`                 | Edit/Write 후 포맷터 자동 실행 (PostToolUse) — **TODO 포맷터 미작성** |
| `.claude/hooks/warn-secrets.sh`                   | 프롬프트에 시크릿 경로가 보이면 경고 (UserPromptSubmit)               |

### 7.2 본인 프로젝트로 옮기는 절차

1. **복사** — `CLAUDE.md`, `.claude/` 를 본인 프로젝트 루트로 복사. `.gitignore` 는 기존 파일에 **병합**.
2. **자동 치환** — 프로젝트 디렉터리에서 `/haruboan:init-project` 실행. 스택 신호 파일(`pyproject.toml`·`package.json`·`go.mod` 등)을 감지해 8개 플레이스홀더를 일괄 치환한다.
3. **개인 시크릿 분리** — `.claude/settings.local.example.json` 을 `.claude/settings.local.json` 으로 복사 후 토큰 입력.
4. **훅 실행권한** — `chmod +x .claude/hooks/*.sh`.
5. **훅 TODO 보강** — `block-dangerous.sh` 위험 패턴, `format-changed.sh` 포맷터 호출은 수동 작성. MCP 서버를 쓰면 `.mcp.json` 도 생성.
6. **검증** — `/haruboan:onboarding-check` 로 ✅/❌ 확인.

### 7.3 일상 워크플로우

| 상황               | 호출                                                               |
| ------------------ | ------------------------------------------------------------------ |
| 커밋 메시지 만들기 | `/haruboan-commit` (스테이징된 것만)                               |
| PR 올리기 전       | `/haruboan-pr-prep` (변경 점검 → 린트 → 테스트 → 컨벤션 → PR 본문) |
| 코드 리뷰 보조     | `@code-reviewer` 또는 `/haruboan:review`                           |
| 마이그레이션 PR    | `@migration-checker`                                               |
| 새 함수 TDD        | `@test-writer` 로 red 테스트 먼저                                  |
