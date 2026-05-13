---
description: 템플릿을 옮긴 직후, 프로젝트 스택을 감지해 <플레이스홀더> 를 일괄 치환
---

이 커맨드는 `CLAUDE.md` / `.claude/settings.json` / `.claude/commands/haruboan/*.md` 의 `<...>` 플레이스홀더를 실제 값으로 바꾼다. 다음 절차를 그대로 따른다.

## 1. 스택 감지

다음 신호 파일을 확인해 언어·툴체인을 추정한다. 여러 개가 잡히면 모두 후보로 둔다.

| 신호                         | 언어        | 기본 추정 lint                              | 기본 추정 test                   | setup                             |
| ---------------------------- | ----------- | ------------------------------------------- | -------------------------------- | --------------------------------- |
| `pyproject.toml` (poetry/uv) | Python      | `ruff check . && ruff format --check .`     | `pytest`                         | `uv sync` 또는 `poetry install`   |
| `requirements.txt`           | Python      | `ruff check .`                              | `pytest`                         | `pip install -r requirements.txt` |
| `package.json`               | JS/TS       | `pnpm lint` 또는 `npm run lint`             | `pnpm test` 또는 `npm test`      | `pnpm install` 또는 `npm ci`      |
| `go.mod`                     | Go          | `golangci-lint run`                         | `go test ./...`                  | `go mod download`                 |
| `Cargo.toml`                 | Rust        | `cargo clippy --all-targets -- -D warnings` | `cargo test`                     | `cargo build`                     |
| `pom.xml` / `build.gradle`   | Java/Kotlin | `./gradlew check` 또는 `mvn verify`         | `./gradlew test` 또는 `mvn test` | `./gradlew build`                 |

추가로 다음을 점검해 보정한다.

- `package.json` 의 `scripts` 키 → 실제 정의된 `lint` / `test` / `typecheck` 스크립트명을 그대로 사용
- `pyproject.toml` 의 `[tool.ruff]` / `[tool.mypy]` 존재 여부로 타입체커·린터 확정
- `.python-version`, `Makefile`, `Justfile` 도 가볍게 확인

## 2. 치환값 제안

다음 표 형식으로 출력한다. 값이 불확실하면 `?` 로 표시하고 사용자에게 묻는다.

| 플레이스홀더              | 제안값 | 근거 |
| ------------------------- | ------ | ---- |
| `<언어>`                  | …      | …    |
| `<포맷터·린터>`           | …      | …    |
| `<설정 통합 파일>`        | …      | …    |
| `<타입 체커>`             | …      | …    |
| `<docstring/주석 스타일>` | …      | …    |
| `<setup_command>`         | …      | …    |
| `<test_command>`          | …      | …    |
| `<lint_command>`          | …      | …    |

사용자 확인 1회: "이대로 치환할까요?" — 수정 요청이 오면 표만 갱신.

## 3. 일괄 치환

확정된 값으로 다음 파일에서 `Edit(replace_all=true)` 를 수행한다. 파일이 없으면 건너뛴다.

- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/commands/haruboan/test.md`
- `.claude/commands/haruboan/review.md`

치환은 **요청된 플레이스홀더 외 다른 줄을 건드리지 않는다** (surgical changes).

## 4. 후속 안내

치환이 끝나면 다음을 한 번에 안내한다.

- `.claude/hooks/*.sh` 의 TODO 영역(위험 패턴·포맷터 호출)은 수동 보강 필요 — 파일 경로 그대로 출력
- `.claude/settings.local.json` 은 `.claude/settings.local.example.json` 을 복사해 생성하라고 안내
- `chmod +x .claude/hooks/*.sh` 실행권한 부여 명령 안내
- 검증용: `/haruboan:onboarding-check` 실행 권장

## 종료 조건

- 3단계 치환 성공 시 변경 파일 목록을 출력하고 종료
- 어느 단계든 실패하면 그 시점까지 결과 + 다음 권장 액션 한 줄 출력 후 종료
- 스택 감지 실패(신호 파일 0개) 시 사용자에게 직접 값 입력을 요청
