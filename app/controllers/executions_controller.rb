class ExecutionsController < ApplicationController
  def index
    @executions = Execution.recent.includes(:prompt, :ai_provider).limit(50)
  end

  def show
    @execution = Execution.find(params[:id])
  end

  def destroy
    @execution = Execution.find(params[:id])
    @execution.destroy
    redirect_to executions_path, notice: "실행 기록이 삭제되었습니다."
  end
end
