# 교육 피드백 롤링페이퍼 (인수인계)

## 한 줄 요약
교육 발표 후 참석자가 소속/부서·닉네임으로 입장해 5점 평가와 포스트잇 의견(잘한 부분/개선이 필요한 부분)을 남기는 정적 웹앱. GitHub Pages + Supabase 무료 플랜. 월요일(2026-10-19) 사내 데모 발표 예정.

## 사용자 정보와 작업 규칙
- 사용자는 간호사 출신이며 의료 데이터 분석을 배우는 초보 개발자. 코드 위치를 모르므로 파일 경로와 수정 위치를 항상 알려줄 것.
- 코드 요청에는 코드만, 일반 질문에는 일반 텍스트로 답할 것. 코드 설명은 코드 내부 주석(첫 줄 기능 설명)으로 쓸 것.
- 객관적으로 판단하고, 리스크와 한계를 함께 말하고, 모르는 것은 모른다고 할 것.
- 절대 유료 기능을 쓰지 말 것: 새 Supabase 프로젝트·브랜치 생성, 유료 플랜, 유료 호스팅 금지. 모든 것은 무료 범위에서만.

## 구성
- 저장소: https://github.com/anywaysoul92/feedback-rolling-paper (public, branch main)
- 배포 주소(예정): https://anywaysoul92.github.io/feedback-rolling-paper/
- 앱 본체: `index.html` 한 파일(HTML+CSS+JS). 상단 `CONFIG`에 제목, Supabase URL/anon 키, 평가 문항 2개(q1, q2), 척도 라벨이 있음.
- `make_qr.py`: `python make_qr.py <주소>` → `qr.png` (`pip install "qrcode[pil]"` 필요)
- `supabase/schema.sql`: 현재 DB 구조를 재현하는 SQL(참고용, 이미 적용됨)

## Supabase (프로젝트명 feedback paper)
- project ref: ecfhsputhgoxrfycmtib, URL: https://ecfhsputhgoxrfycmtib.supabase.co, region ap-northeast-2
- anon(공개용) 키는 index.html에 들어 있고 공개돼도 설계상 괜찮음. service_role 키는 절대 코드·저장소에 넣지 말 것.
- 테이블
  - `feedback`: 메모. anon은 SELECT만 가능. 쓰기는 RPC로만(`add_feedback`, `edit_feedback`, `delete_feedback`).
  - `feedback_owner`: 메모별 비밀 토큰(uuid). anon 접근 전부 차단(RLS, 정책 없음). 토큰은 작성 기기 localStorage `fb_mine`에만 있음.
  - `rating`: 평점(dept, q1, q2). anon이 SELECT/INSERT 가능, 수정·삭제 불가. 1인 1회는 localStorage `fb_rated`로만 제어(우회 가능).
- 수정·삭제는 작성한 기기·브라우저에서만 가능(토큰 일치). anon에 feedback INSERT/UPDATE/DELETE 권한을 다시 열지 말 것.
- 부적절한 메모 삭제는 Supabase 대시보드 Table Editor에서만 가능.
- Realtime: feedback, rating이 publication에 등록돼 있음.

## 현재 상태 (2026-10-18 기준)
완료
- 화면 흐름: 소속/부서 입력 → 평점 설문(건너뛰기 가능) → 보드. 노트북(2단)과 폰 반응형. 필터(전체/잘한 부분/개선이 필요한 부분), "감사합니다 ☺️" 팝업, 안내 문구, 하단 문의 이메일.
- DB 테이블, RLS, RPC 적용 및 익명 권한 검증(올바른 토큰만 수정·삭제됨).
- 가상 브라우저(미리보기 모드)로 화면 흐름 테스트.

미완료
1. GitHub Pages 켜기: 현재 404. Settings → Pages → Deploy from a branch → main / (root). 로컬 gh 인증이 있으면 `gh api -X POST repos/anywaysoul92/feedback-rolling-paper/pages -f "source[branch]=main" -f "source[path]=/"`.
2. 최신 index.html(문의 이메일 푸터 포함) 반영: 저장소의 index.html은 푸터 이전 버전일 수 있음. `git pull` 후 이 폴더의 최신본으로 교체해 커밋·푸시.
3. 실제 배포 주소에서 실접속 테스트(아직 한 번도 못 함): 메모 작성 → Table Editor 반영 → 수정 → 삭제, 폰 두 대로 실시간 반영, 회사 네트워크에서 QR 접속.
4. 접속이 확인되면 QR을 최종 주소로 다시 생성(`qr.png`).
5. 테스트 데이터 삭제(Table Editor).

## 알려진 한계
- 로그인이 없어 스팸·사칭을 완전히 막지 못함. 닉네임은 자유 입력.
- 무료 플랜은 일정 기간 접속이 없으면 프로젝트가 일시 중지될 수 있음(추정). 발표 당일 오전에 한 번 접속해 확인.
- 평점은 평균만 보면 왜곡되므로 응답 수와 분포를 같이 봐야 함(보드 상단에 표시됨).
- 저장소가 public이라 코드와 문의 이메일(jmkim@jlkgroup.com)이 공개됨.
- Supabase가 보내는 realtime 이벤트로 보드가 갱신되며 20초마다 새로고침도 함.

## 발표 후 마무리
- 쓰기 차단: `revoke execute on function public.add_feedback(text,text,text,text,uuid) from anon;` 및 rating의 insert 정책 제거.
- 데이터 내보내기: Table Editor에서 CSV 다운로드.
