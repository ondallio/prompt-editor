module NotesHelper
  def render_note_content(note)
    html = ERB::Util.html_escape(note.content.to_s)

    # [[링크]]를 클릭 가능한 링크로 변환
    html = html.gsub(/\[\[([^\]]+)\]\]/) do
      text = Regexp.last_match(1)
      target = Note.find_by(title: text)
      if target
        link_to("[[#{text}]]", note_path(target), class: "text-indigo-600 hover:text-indigo-500 font-medium no-underline")
      else
        link_to("[[#{text}]]", new_note_path(title: text), class: "text-orange-500 hover:text-orange-400 font-medium no-underline")
      end
    end

    # #태그를 클릭 가능한 링크로 변환
    html = html.gsub(/(^|\s)#([\w가-힣]+)/) do
      prefix = Regexp.last_match(1)
      tag_name = Regexp.last_match(2)
      "#{prefix}#{link_to("##{tag_name}", tag_path(tag_name), class: "text-emerald-600 hover:text-emerald-500 font-medium no-underline")}".html_safe
    end

    html.html_safe
  end
end
