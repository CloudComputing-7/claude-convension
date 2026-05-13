#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# warn-secrets.sh — UserPromptSubmit hook
#
# 목적: 사용자가 프롬프트에 시크릿 파일 경로/패턴을 언급하면 경고.
#       (실제 파일 내용이 컨텍스트로 들어가기 전에 한 번 경고할 기회 확보)
#
# 동작:
#   - stdin 으로 JSON 이 들어옴 (prompt 필드에 사용자 입력)
#   - 패턴 매치 시 stdout 으로 경고를 추가 컨텍스트로 주입 (exit 0)
#   - 차단은 하지 않는다 (사용자 의도가 정당할 수 있으므로)
#
# ⚠️  이 파일은 템플릿입니다. 팀 환경에 맞춰 패턴을 보강하세요.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

INPUT="$(cat)"
PROMPT="$(printf '%s' "$INPUT" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')"

# TODO: 팀에서 다루는 시크릿 경로/패턴을 추가하세요.
SECRET_PATTERNS=(
  '\.env(\.|$)'
  'id_rsa'
  '\.pem$'
  '\.p12$'
  'credentials\.json'
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if printf '%s' "$PROMPT" | grep -Eiq "$pattern"; then
    echo "[warn-secrets] 주의: 프롬프트가 시크릿 파일 패턴('$pattern')을 포함합니다. 해당 파일을 컨텍스트로 노출하기 전에 확인하세요."
    break
  fi
done

exit 0
