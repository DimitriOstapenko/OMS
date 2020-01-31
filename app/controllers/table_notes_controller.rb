class TableNotesController < ApplicationController
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update]
  before_action :admin_user, only: [:destroy]

  def new
    @table_note = TableNote.new
  end

  def index
    @table_notes = TableNote.all
    if @table_notes.any?
        @table_notes = @table_notes.paginate(page: params[:page])
    else
        render inline: '', layout: true
    end
  end

  def show
    @table_note = TableNote.find(params[:id]) rescue nil
    redirect_to table_notes_path unless @table_note
  end

  def create
    @table_note = TableNote.new(table_note_params)
    if @table_note.save
       flash[:success] = "New table notes created"
       redirect_to table_notes_path
    else
       render 'new'
    end
  end



private
  def table_note_params
    params.require(:table_note).permit( :table_name, :notes)
  end

end
