class AiProvidersController < ApplicationController
  before_action :set_ai_provider, only: [:show, :edit, :update, :destroy]

  def index
    @ai_providers = AiProvider.ordered
  end

  def show
  end

  def new
    @ai_provider = AiProvider.new
  end

  def create
    @ai_provider = AiProvider.new(ai_provider_params)
    if @ai_provider.save
      redirect_to ai_providers_path, notice: "AI 프로바이더가 등록되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @ai_provider.update(ai_provider_params)
      redirect_to ai_providers_path, notice: "AI 프로바이더가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ai_provider.destroy
    redirect_to ai_providers_path, notice: "AI 프로바이더가 삭제되었습니다."
  end

  private

  def set_ai_provider
    @ai_provider = AiProvider.find(params[:id])
  end

  def ai_provider_params
    params.require(:ai_provider).permit(:name, :provider_type, :api_key, :ai_model, :endpoint_url, :active)
  end
end
