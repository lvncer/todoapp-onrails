class TodosController < ApplicationController
  before_action :set_todo, only: [ :show, :edit, :update, :destroy ]

  # GET /todos
  def index
    @todos = Todo.recent
  end

  # GET /todos/:id
  def show
  end

  # GET /todos/new
  def new
    @todo = Todo.new
  end

  # POST /todos
  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      redirect_to @todo, notice: "Todo was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /todos/:id/edit
  def edit
  end

  # PATCH/PUT /todos/:id
  def update
    if @todo.update(todo_params)
      redirect_to @todo, notice: "Todo was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /todos/:id
  def destroy
    @todo.destroy
    redirect_to todos_url, notice: "Todo was successfully deleted."
  end

  # PATCH /todos/:id/toggle
  def toggle
    @todo = Todo.find(params[:id])
    @todo.toggle_completed!
    redirect_to todos_path, notice: "Todo was marked as #{@todo.completed? ? 'completed' : 'pending'}."
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :completed)
  end
end
