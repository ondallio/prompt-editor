# ===========================================
# 카테고리
# ===========================================
categories = {
  "코딩" => { description: "코드 생성, 리팩토링, 디버깅", color: "#3B82F6" },
  "글쓰기" => { description: "블로그, 이메일, 문서 작성", color: "#10B981" },
  "번역" => { description: "다국어 번역", color: "#F59E0B" },
  "분석" => { description: "데이터 분석, 요약", color: "#8B5CF6" },
  "마케팅" => { description: "광고, SNS, 카피라이팅", color: "#EC4899" },
  "교육" => { description: "학습 자료, 퀴즈, 설명", color: "#06B6D4" },
  "비즈니스" => { description: "기획서, 보고서, 이메일", color: "#F97316" },
  "창작" => { description: "소설, 시, 스토리텔링", color: "#6366F1" }
}

categories.each do |name, attrs|
  Category.find_or_create_by!(name: name) do |c|
    c.description = attrs[:description]
    c.color = attrs[:color]
  end
end

puts "카테고리 #{Category.count}개 생성 완료"

# ===========================================
# 프롬프트
# ===========================================
coding = Category.find_by!(name: "코딩")
writing = Category.find_by!(name: "글쓰기")
translation = Category.find_by!(name: "번역")
analysis = Category.find_by!(name: "분석")
marketing = Category.find_by!(name: "마케팅")
education = Category.find_by!(name: "교육")
business = Category.find_by!(name: "비즈니스")
creative = Category.find_by!(name: "창작")

prompts_data = [
  # 코딩
  {
    title: "코드 리뷰",
    category: coding,
    favorite: true,
    system_prompt: "당신은 시니어 소프트웨어 엔지니어입니다. 코드를 꼼꼼히 리뷰해주세요.",
    content: "다음 {{언어}} 코드를 리뷰해주세요:\n\n{{코드}}\n\n다음 관점에서 리뷰해주세요:\n1. 버그 가능성\n2. 성능 개선\n3. 코드 스타일\n4. 보안 이슈"
  },
  {
    title: "함수 작성",
    category: coding,
    system_prompt: "당신은 클린 코드를 작성하는 개발자입니다. 읽기 쉽고 유지보수가 용이한 코드를 작성합니다.",
    content: "{{언어}}로 다음 기능을 하는 함수를 작성해주세요:\n\n기능: {{기능설명}}\n\n입력: {{입력}}\n출력: {{출력}}\n\n에러 처리와 엣지 케이스도 고려해주세요."
  },
  {
    title: "버그 디버깅",
    category: coding,
    system_prompt: "당신은 디버깅 전문가입니다. 에러 메시지와 코드를 분석하여 원인을 찾아냅니다.",
    content: "다음 에러가 발생했습니다:\n\n에러 메시지: {{에러메시지}}\n\n관련 코드:\n{{코드}}\n\n환경: {{환경}}\n\n원인을 분석하고 해결 방법을 알려주세요."
  },
  {
    title: "SQL 쿼리 작성",
    category: coding,
    system_prompt: "당신은 데이터베이스 전문가입니다. 효율적인 SQL 쿼리를 작성합니다.",
    content: "다음 요구사항에 맞는 SQL 쿼리를 작성해주세요.\n\nDB 종류: {{DB종류}}\n테이블 구조:\n{{테이블구조}}\n\n요구사항: {{요구사항}}\n\n성능 최적화도 고려해주세요."
  },
  {
    title: "리팩토링 제안",
    category: coding,
    favorite: true,
    system_prompt: "당신은 소프트웨어 아키텍트입니다. 코드의 구조적 개선점을 제안합니다.",
    content: "다음 {{언어}} 코드를 리팩토링해주세요:\n\n{{코드}}\n\n리팩토링 관점:\n- SOLID 원칙 적용\n- 중복 코드 제거\n- 가독성 향상\n- 테스트 용이성"
  },

  # 글쓰기
  {
    title: "블로그 포스트 작성",
    category: writing,
    system_prompt: "당신은 전문 블로거입니다. 독자를 끌어들이는 매력적인 글을 작성합니다.",
    content: "{{주제}}에 대한 블로그 포스트를 작성해주세요.\n\n타겟 독자: {{독자층}}\n톤: {{톤}}\n길이: 약 {{길이}}자"
  },
  {
    title: "이메일 작성",
    category: writing,
    system_prompt: "당신은 비즈니스 커뮤니케이션 전문가입니다. 명확하고 예의 바른 이메일을 작성합니다.",
    content: "다음 상황에 맞는 이메일을 작성해주세요.\n\n받는 사람: {{수신자}}\n목적: {{목적}}\n핵심 내용: {{내용}}\n톤: {{톤}}"
  },
  {
    title: "문서 요약",
    category: writing,
    system_prompt: "당신은 편집 전문가입니다. 핵심을 놓치지 않으면서 간결하게 요약합니다.",
    content: "다음 문서를 {{길이}}자 이내로 요약해주세요.\n\n요약 형식: {{형식}}\n\n원본 문서:\n{{문서}}"
  },

  # 번역
  {
    title: "다국어 번역",
    category: translation,
    favorite: true,
    system_prompt: "당신은 전문 번역가입니다. 자연스러운 표현으로 번역합니다.",
    content: "다음 텍스트를 {{원본언어}}에서 {{대상언어}}로 번역해주세요.\n자연스러운 표현을 사용하고, 전문 용어는 원어를 병기해주세요.\n\n번역할 텍스트:\n{{텍스트}}"
  },
  {
    title: "기술 문서 번역",
    category: translation,
    system_prompt: "당신은 기술 번역 전문가입니다. 기술 용어의 정확성을 유지하면서 번역합니다.",
    content: "다음 기술 문서를 {{원본언어}}에서 {{대상언어}}로 번역해주세요.\n\n분야: {{분야}}\n\n기술 용어는 영문을 병기하고, 코드 블록은 그대로 유지해주세요.\n\n원문:\n{{텍스트}}"
  },

  # 분석
  {
    title: "데이터 분석 요청",
    category: analysis,
    system_prompt: "당신은 데이터 분석가입니다. 데이터에서 의미 있는 인사이트를 도출합니다.",
    content: "다음 데이터를 분석해주세요:\n\n{{데이터}}\n\n분석 관점:\n1. 주요 트렌드\n2. 이상치\n3. 핵심 인사이트\n4. 개선 제안\n\n출력 형식: {{형식}}"
  },
  {
    title: "경쟁사 분석",
    category: analysis,
    system_prompt: "당신은 비즈니스 전략 분석가입니다. 객관적이고 체계적인 분석을 제공합니다.",
    content: "{{업종}} 분야에서 다음 경쟁사를 분석해주세요:\n\n우리 회사: {{우리회사}}\n경쟁사: {{경쟁사}}\n\n분석 항목:\n1. 강점/약점 비교\n2. 시장 포지셔닝\n3. 차별화 포인트\n4. 전략적 시사점"
  },
  {
    title: "텍스트 감정 분석",
    category: analysis,
    system_prompt: "당신은 자연어 처리 전문가입니다. 텍스트의 감정과 톤을 정확히 파악합니다.",
    content: "다음 텍스트의 감정을 분석해주세요:\n\n{{텍스트}}\n\n분석 항목:\n- 전체 감정 (긍정/부정/중립)\n- 감정 강도 (1-10)\n- 세부 감정 (기쁨, 분노, 슬픔 등)\n- 핵심 키워드"
  },

  # 마케팅
  {
    title: "SNS 게시물 작성",
    category: marketing,
    system_prompt: "당신은 소셜미디어 마케터입니다. 바이럴될 수 있는 매력적인 콘텐츠를 만듭니다.",
    content: "{{플랫폼}}에 올릴 게시물을 작성해주세요.\n\n제품/서비스: {{제품}}\n타겟 고객: {{타겟}}\n목적: {{목적}}\n톤: {{톤}}\n\n해시태그도 포함해주세요."
  },
  {
    title: "광고 카피 작성",
    category: marketing,
    favorite: true,
    system_prompt: "당신은 카피라이터입니다. 고객의 마음을 움직이는 문구를 만듭니다.",
    content: "다음 제품의 광고 카피를 {{개수}}개 작성해주세요.\n\n제품명: {{제품명}}\n핵심 가치: {{핵심가치}}\n타겟: {{타겟}}\n매체: {{매체}}\n\n각 카피에 대해 의도와 효과를 설명해주세요."
  },
  {
    title: "SEO 키워드 분석",
    category: marketing,
    system_prompt: "당신은 SEO 전문가입니다. 검색 최적화를 위한 전략적 키워드를 제안합니다.",
    content: "{{주제}} 관련 SEO 키워드를 분석해주세요.\n\n대상 시장: {{시장}}\n경쟁 강도: {{경쟁강도}}\n\n제안 항목:\n1. 메인 키워드 5개\n2. 롱테일 키워드 10개\n3. 관련 키워드 클러스터\n4. 콘텐츠 전략 제안"
  },

  # 교육
  {
    title: "개념 설명",
    category: education,
    system_prompt: "당신은 교육 전문가입니다. 복잡한 개념을 쉽고 명확하게 설명합니다.",
    content: "{{개념}}을(를) 설명해주세요.\n\n대상 수준: {{수준}}\n\n다음을 포함해주세요:\n1. 핵심 정의\n2. 비유/예시\n3. 관련 개념과의 차이\n4. 실생활 활용 사례"
  },
  {
    title: "퀴즈 생성",
    category: education,
    system_prompt: "당신은 교육 평가 전문가입니다. 학습 효과를 높이는 문제를 출제합니다.",
    content: "{{주제}}에 대한 퀴즈를 {{개수}}문제 만들어주세요.\n\n난이도: {{난이도}}\n문제 유형: {{유형}}\n\n각 문제에 정답과 해설을 포함해주세요."
  },

  # 비즈니스
  {
    title: "기획서 작성",
    category: business,
    system_prompt: "당신은 기획 전문가입니다. 논리적이고 설득력 있는 기획서를 작성합니다.",
    content: "다음 프로젝트의 기획서를 작성해주세요.\n\n프로젝트명: {{프로젝트명}}\n목적: {{목적}}\n예산: {{예산}}\n기간: {{기간}}\n\n포함 항목:\n1. 배경 및 필요성\n2. 목표\n3. 실행 계획\n4. 기대 효과\n5. 리스크 관리"
  },
  {
    title: "회의록 정리",
    category: business,
    system_prompt: "당신은 비서입니다. 회의 내용을 체계적으로 정리합니다.",
    content: "다음 회의 내용을 정리해주세요:\n\n{{회의내용}}\n\n형식:\n- 참석자\n- 안건\n- 주요 논의 사항\n- 결정 사항\n- 액션 아이템 (담당자, 기한)"
  },

  # 창작
  {
    title: "단편 소설 작성",
    category: creative,
    system_prompt: "당신은 소설가입니다. 몰입감 있는 이야기를 만듭니다.",
    content: "다음 설정으로 단편 소설을 작성해주세요.\n\n장르: {{장르}}\n배경: {{배경}}\n주인공: {{주인공}}\n핵심 갈등: {{갈등}}\n분량: 약 {{분량}}자"
  },
  {
    title: "캐릭터 설정",
    category: creative,
    system_prompt: "당신은 스토리텔링 전문가입니다. 입체적이고 매력적인 캐릭터를 설계합니다.",
    content: "다음 조건으로 캐릭터를 만들어주세요.\n\n역할: {{역할}}\n장르: {{장르}}\n\n포함 항목:\n- 이름, 나이, 외모\n- 성격 (MBTI 포함)\n- 배경 스토리\n- 동기와 목표\n- 약점과 결함\n- 말투 예시"
  }
]

prompts_data.each do |data|
  Prompt.find_or_create_by!(title: data[:title]) do |p|
    p.category = data[:category]
    p.system_prompt = data[:system_prompt]
    p.content = data[:content]
    p.favorite = data[:favorite] || false
  end
end

puts "프롬프트 #{Prompt.count}개 생성 완료"

# ===========================================
# AI Provider (API 키는 플레이스홀더)
# ===========================================
providers_data = [
  {
    name: "OpenAI GPT-4o",
    provider_type: "openai",
    api_key: ENV.fetch("OPENAI_API_KEY", "sk-placeholder"),
    ai_model: "gpt-4o",
    active: true
  },
  {
    name: "Claude Sonnet",
    provider_type: "anthropic",
    api_key: ENV.fetch("ANTHROPIC_API_KEY", "sk-placeholder"),
    ai_model: "claude-sonnet-4-20250514",
    active: true
  },
  {
    name: "Gemini Flash",
    provider_type: "gemini",
    api_key: ENV.fetch("GEMINI_API_KEY", "sk-placeholder"),
    ai_model: "gemini-2.0-flash",
    active: false
  }
]

providers_data.each do |data|
  AiProvider.find_or_create_by!(name: data[:name]) do |p|
    p.provider_type = data[:provider_type]
    p.api_key = data[:api_key]
    p.ai_model = data[:ai_model]
    p.active = data[:active]
  end
end

puts "AI Provider #{AiProvider.count}개 생성 완료"

# ===========================================
# 샘플 실행 기록
# ===========================================
provider = AiProvider.find_by(name: "OpenAI GPT-4o")
code_review = Prompt.find_by(title: "코드 리뷰")
blog_post = Prompt.find_by(title: "블로그 포스트 작성")

if provider && code_review
  Execution.find_or_create_by!(prompt: code_review, ai_provider: provider, status: "completed") do |e|
    e.input_variables = { "언어" => "Ruby", "코드" => "def hello\n  puts 'hello'\nend" }
    e.rendered_content = "다음 Ruby 코드를 리뷰해주세요:\n\ndef hello\n  puts 'hello'\nend\n\n다음 관점에서 리뷰해주세요:\n1. 버그 가능성\n2. 성능 개선\n3. 코드 스타일\n4. 보안 이슈"
    e.response_text = "코드 리뷰 결과: 간단한 메서드이지만, frozen_string_literal 매직 코멘트 추가를 권장합니다."
    e.token_count = 150
    e.duration_ms = 1200
  end
end

if provider && blog_post
  Execution.find_or_create_by!(prompt: blog_post, ai_provider: provider, status: "completed") do |e|
    e.input_variables = { "주제" => "AI 트렌드", "독자층" => "개발자", "톤" => "친근한", "길이" => "1500" }
    e.rendered_content = "AI 트렌드에 대한 블로그 포스트를 작성해주세요.\n\n타겟 독자: 개발자\n톤: 친근한\n길이: 약 1500자"
    e.response_text = "2026년 AI 트렌드를 살펴보겠습니다. 올해는 특히 에이전트 AI가 주목받고 있습니다..."
    e.token_count = 520
    e.duration_ms = 3400
  end
end

puts "실행 기록 #{Execution.count}개 생성 완료"
puts "=" * 50
puts "Seed 완료!"
puts "  카테고리: #{Category.count}개"
puts "  프롬프트: #{Prompt.count}개"
puts "  AI Provider: #{AiProvider.count}개"
puts "  실행 기록: #{Execution.count}개"
puts "=" * 50
