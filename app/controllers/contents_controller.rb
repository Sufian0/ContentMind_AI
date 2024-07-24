class ContentsController < ApplicationController

  def index
    @contents = Content.all.order(created_at: :desc)
  end

  def index
    @contents = Content.all
  end

  def show
    @content = Content.find(params[:id])
    record_interaction('view', 1.0)
  end

  def new
    @content = Content.new
  end

  def create
    @content = Content.new(content_params)
    if @content.save
      redirect_to root_path, notice: 'Content was successfully created.'
    else
      render :new
    end
  end

  def like
    @content = Content.find(params[:id])
    record_interaction('like', 1.0)
    redirect_to @content, notice: 'Content liked!'
  end

  private

  def content_params
    params.require(:content).permit(:title, :description, :category)
  end

  def record_interaction(type, value)
    UserInteraction.create(
      user: current_user,
      content: @content,
      interaction_type: type,
      interaction_value: value
    )
  end
end