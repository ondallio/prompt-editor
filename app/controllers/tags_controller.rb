class TagsController < ApplicationController
  def index
    @tags = Tag.popular.includes(:notes)
  end

  def show
    @tag = Tag.find_by!(name: params[:name])
    @tagged_notes = @tag.notes.includes(:tags).order(updated_at: :desc)
    @unlinked_notes = @tag.unlinked_references.limit(20)
  end
end
