# #!/usr/bin/env bash
# # ─────────────────────────────────────────────────────────────────────────────
# # block-dangerous.sh — PreToolUse hook (matcher: Bash)
# #
# # ⚠️  이 파일은 템플릿입니다.
# #     아래 TODO 의 정규식을 팀이 채우기 전까지는 어떤 명령도 차단하지 않습니다.
# #     위험 명령 차단의 1차 방어선은 `.claude/settings.json` 의 permissions.deny 입니다.
# #     이 hook 은 deny 패턴으로 잡기 어려운 조합(파이프·치환·다단계)을 한 번 더 거르기 위한 것입니다.
# #
# # 동작:
# #   - stdin 으로 JSON 이 들어옴 (tool_input.command 에 실행 예정 셸 명령이 있음)
# #   - 위험 패턴이 매치되면 stderr 에 사유 출력 + exit 2 → 도구 호출 거부
# #   - 그 외에는 exit 0
# # ─────────────────────────────────────────────────────────────────────────────
# set -euo pipefail

# INPUT="$(cat)"
# CMD="$(printf '%s' "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

# # TODO: 팀 합의된 위험 패턴을 추가하세요. 예시 (주석 해제 후 사용):
# # DANGEROUS_PATTERNS=(
# #   'rm[[:space:]]+-rf[[:space:]]+/'
# #   'git[[:space:]]+push[[:space:]]+--force'
# #   ':\(\)\{[[:space:]]*:\|:&[[:space:]]*\};:'   # fork bomb
# #   'curl[[:space:]]+[^|]*\|[[:space:]]*sh'      # curl | sh
# # )
# DANGEROUS_PATTERNS=()

# for pattern in "${DANGEROUS_PATTERNS[@]:-}"; do
#   if printf '%s' "$CMD" | grep -Eq "$pattern"; then
#     echo "[block-dangerous] 차단됨: '$pattern' 매치 — '$CMD'" >&2
#     exit 2
#   fi
# done

# exit 0
