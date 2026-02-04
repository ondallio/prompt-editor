# 카테고리
categories = {
  "코딩" => { description: "코드 생성, 리팩토링, 디버깅", color: "#3B82F6" },
  "글쓰기" => { description: "블로그, 이메일, 문서 작성", color: "#10B981" },
  "번역" => { description: "다국어 번역", color: "#F59E0B" },
  "분석" => { description: "데이터 분석, 요약", color: "#8B5CF6" },
  "마케팅" => { description: "광고, SNS, 카피라이팅", color: "#EC4899" }
}

categories.each do |name, attrs|
  Category.find_or_create_by!(name: name) do |c|
    c.description = attrs[:description]
    c.color = attrs[:color]
  end
end

# 샘플 프롬프트
coding = Category.find_by(name: "코딩")
writing = Category.find_by(name: "글쓰기")
translation = Category.find_by(name: "번역")

Prompt.find_or_create_by!(title: "코드 리뷰") do |p|
  p.category = coding
  p.system_prompt = "당신은 시니어 소프트웨어 엔지니어입니다. 코드를 꼼꼼히 리뷰해주세요."
  p.content = "다음 {{언어}} 코드를 리뷰해주세요:\n\n{{코드}}\n\n다음 관점에서 리뷰해주세요:\n1. 버그 가능성\n2. 성능 개선\n3. 코드 스타일\n4. 보안 이슈"
end

Prompt.find_or_create_by!(title: "블로그 포스트 작성") do |p|
  p.category = writing
  p.system_prompt = "당신은 전문 블로거입니다. 독자를 끌어들이는 매력적인 글을 작성합니다."
  p.content = "{{주제}}에 대한 블로그 포스트를 작성해주세요.\n\n타겟 독자: {{독자층}}\n톤: {{톤}}\n길이: 약 {{길이}}자"
end

Prompt.find_or_create_by!(title: "다국어 번역") do |p|
  p.category = translation
  p.content = "다음 텍스트를 {{원본언어}}에서 {{대상언어}}로 번역해주세요.\n자연스러운 표현을 사용하고, 전문 용어는 원어를 병기해주세요.\n\n번역할 텍스트:\n{{텍스트}}"
end

puts "Seed 완료: #{Category.count}개 카테고리, #{Prompt.count}개 프롬프트"
