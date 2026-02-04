class PromptsController < ApplicationController
  before_action :set_prompt, only: [:show, :edit, :update, :destroy, :toggle_favorite, :execute, :versions, :restore_version]

  def index
    @prompts = Prompt.includes(:category, :variables).ordered
    @prompts = @prompts.by_category(params[:category_id]) if params[:category_id].present?
    @prompts = @prompts.favorites if params[:favorites] == "true"
    @prompts = @prompts.where("title ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @categories = Category.ordered
  end

  def show
    @ai_providers = AiProvider.active.ordered
    @recent_executions = @prompt.executions.recent.limit(5).includes(:ai_provider)
  end

  def new
    @prompt = Prompt.new(category_id: params[:category_id])
    @categories = Category.ordered
  end

  def create
    @prompt = Prompt.new(prompt_params)
    if @prompt.save
      redirect_to @prompt, notice: "프롬프트가 생성되었습니다."
    else
      @categories = Category.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.ordered
  end

  def update
    if @prompt.update(prompt_params)
      redirect_to @prompt, notice: "프롬프트가 수정되었습니다."
    else
      @categories = Category.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @prompt.destroy
    redirect_to prompts_path, notice: "프롬프트가 삭제되었습니다."
  end

  def toggle_favorite
    @prompt.update!(favorite: !@prompt.favorite)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @prompt }
    end
  end

  def execute
    ai_provider = AiProvider.find(params[:ai_provider_id])
    variable_values = params[:variables]&.to_unsafe_h || {}

    rendered = @prompt.render_content(variable_values)
    execution = @prompt.executions.create!(
      ai_provider: ai_provider,
      input_variables: variable_values,
      rendered_content: rendered,
      status: "pending"
    )

    AiExecutionService.new(execution).call

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "execution-result",
          partial: "prompts/execution_result",
          locals: { execution: execution }
        )
      }
      format.html { redirect_to @prompt }
    end
  end

  def versions
    @versions = @prompt.versions.ordered
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def restore_version
    version = @prompt.versions.find(params[:version_id])
    @prompt.update!(content: version.content, system_prompt: version.system_prompt)
    redirect_to @prompt, notice: "v#{version.version_number}으로 복원되었습니다."
  end

  private

  def set_prompt
    @prompt = Prompt.find(params[:id])
  end

  def prompt_params
    params.require(:prompt).permit(:title, :content, :category_id, :system_prompt)
  end
end
