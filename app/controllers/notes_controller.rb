class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy, :toggle_favorite, :auto_tag]

  def index
    @notes = Note.includes(:tags).ordered
    @notes = @notes.search(params[:q]) if params[:q].present?
    @notes = @notes.favorites if params[:favorites] == "true"
    if params[:tag].present?
      @notes = @notes.joins(:tags).where(tags: { name: params[:tag] }).distinct
    end
    @popular_tags = Tag.popular.limit(20)
  end

  def show
    @linked_references = @note.linked_references.includes(:tags).limit(20)
    @unlinked_references = @note.unlinked_references.limit(20)
    @outgoing_links = @note.outgoing_links.includes(:target_note)
    @ai_providers = AiProvider.active.ordered
  end

  def new
    @note = Note.new(title: params[:title])
  end

  def create
    @note = Note.new(note_params)
    if @note.save
      sync_manual_tags_and_links
      redirect_to @note, notice: "노트가 생성되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @note.update(note_params)
      sync_manual_tags_and_links
      redirect_to @note, notice: "노트가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path, notice: "노트가 삭제되었습니다."
  end

  def toggle_favorite
    @note.update!(favorite: !@note.favorite)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @note }
    end
  end

  def auto_tag
    provider = if params[:ai_provider_id].present?
                 AiProvider.find(params[:ai_provider_id])
               else
                 AiProvider.active.first
               end

    @result = NoteAutoTagService.new(@note, provider: provider).call

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @note, notice: "AI 태깅 완료" }
    end
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content)
  end

  def sync_manual_tags_and_links
    # #태그 동기화
    @note.extract_hash_tags.each do |name|
      tag = Tag.find_or_create_by!(name: name.downcase) { |t| t.color = Tag::COLORS.sample }
      @note.note_tags.find_or_create_by!(tag: tag, ai_generated: false)
    end

    # [[링크]] 동기화
    @note.extract_wiki_links.each do |text|
      @note.outgoing_links.find_or_create_by!(linked_text: text, ai_generated: false)
    end
  end
end
