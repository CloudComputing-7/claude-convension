---
name: harunboan-commit
description: 스테이징된 변경(`git diff --cached`)을 분석해 Conventional Commits 규칙에 맞는 커밋 메시지를 만들고 커밋한다. "커밋 만들어줘" / `/haruboan:commit` 으로 호출.
---

# Conventional Commit 만들기

스테이징된 변경만 대상으로 한다. 미스테이징·untracked 파일은 자동으로 `add` 하지 않는다.

## 1. 변경 스캐닝

- `git status --short` 로 스테이징 / 미스테이징 / untracked 를 분리해 표시.
- `git diff --cached --stat` 으로 변경 파일 목록, `git diff --cached` 로 본문 확인.
- 스테이징된 변경이 비어 있으면 즉시 종료하고 "`git add <files>` 후 다시 호출하세요" 안내.
- 미스테이징·untracked 파일은 목록만 알리고 진행 (자동 add 금지).

## 2. type · scope · 요약 초안
커밋은 3가지 부분으로 이루어집니다. 

Header : 어떤 내용의 커밋인지 선언합니다. 대문자로 시작합니다.

Feat : 기능추가 , 삭제 , 변경
Fix : 버그 수정
Refactor : 코드 구조 변경, 리팩토링
Test : 테스트코드 작성
Docs : 문서 작성, 변경
Etc : 위에 해당하지 않는 여러 사유, 제목에 상세히 명시

Title : 커밋의 제목을 선언합니다. ~~구현, ~~수정 등, 단순하고 명확하게 작성합니다. 

Body : 실제 구현한 내용을 작성합니다. 헤더에서 충분히 설명 되었다면 생략 가능합니다. 

Footer : 참조할 레퍼런스가 있다면 작성합니다. 생략 가능합니다.

```
eg) Feat : 비밀번호 암호화 추가

user.service에 비밀번호 hash로직을 추가하였습니다.

Issue#1234
```

3가지 부분은 공백으로 구분하여 작성합니다.


- scope: 변경 경로의 공통 디렉터리에서 추출 (예: `.claude/skills`, `src/auth`). 너무 넓으면 생략.
- 제목: `type(scope): 요약` 형식, 1줄, 72자 이하, 한국어로 작성.
- 본문: bullet 2~4개로 **왜 / 무엇 / 영향**을 짧게.
- 여러 type 이 섞이면 표로 분할 후보(파일 묶음 ↔ type)를 제시하고 분할 여부를 사용자에게 묻는다. 사용자가 "한 커밋"을 선호하면 가장 대표적인 type 하나로 합친다.

## 3. 사용자 확인

- 초안 메시지를 코드블록으로 출력하고 "이대로 커밋할까요?" 1회만 확인.
- 수정 요청이 오면 메시지만 갱신 — 1단계부터 다시 돌지 않는다.

## 4. 커밋 실행

- HEREDOC 으로 `git commit` 실행:

  ```bash
  git commit -m "$(cat <<'EOF'
  <title>

  - <bullet 1>
  - <bullet 2>
  EOF
  )"
  ```

- 분할로 결정됐다면 자동으로 `git reset` 하지 않는다. 사용자에게 의도한 파일별로 다시 `git add` 하라고 안내한 뒤, 묶음마다 본 스킬을 재호출.
- pre-commit 훅 실패 시 출력 그대로 보고하고 멈춤. `--no-verify` 사용 금지.

## 5. 결과 보고

- `git log -1 --stat` 으로 방금 만든 커밋 확인.
- 다음 권장 액션 한 줄: `/haruboan:pr-prep` 으로 PR 준비 이어가기.

## 종료 조건

- 4단계 커밋 성공 또는 사용자 취소 시 종료.
- 어느 단계든 실패하면 그 시점까지 결과 + 다음 권장 액션 한 줄 출력 후 종료.
