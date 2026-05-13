#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# format-changed.sh — PostToolUse hook (matcher: Edit|Write)
#
# 목적: Claude 가 파일을 수정한 직후 프로젝트 포맷터를 자동 실행.
#
# 동작:
#   - stdin 으로 JSON 이 들어옴 (tool_input.file_path 에 변경 경로)
#   - 확장자에 맞는 포맷터를 호출
#   - 실패해도 exit 0 (포맷 실패가 도구 실행 결과를 뒤집지 않도록)
#
# ⚠️  이 파일은 템플릿입니다. 아래 TODO 의 포맷터 명령을 팀 스택에 맞춰 채우세요.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

INPUT="$(cat)"
FILE="$(printf '%s' "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

[[ -z "$FILE" || ! -f "$FILE" ]] && exit 0

# TODO: 팀 스택에 맞춰 채우세요.
case "$FILE" in
  # *.py)        ruff format "$FILE"     ;;
  # *.ts|*.tsx)  biome format --write "$FILE" ;;
  # *.go)        gofmt -w "$FILE"        ;;
  *) : ;;  # no-op
esac

exit 0
