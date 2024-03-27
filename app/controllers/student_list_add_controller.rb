require 'csv'

class StudentListAddController < ApplicationController
  def import_home
    uploaded_file = params[:file]

    if uploaded_file.blank?
      flash[:error] = "Please select a file to upload."
      redirect_to root_path and return
    end

    if uploaded_file.content_type != 'text/csv'
      flash[:error] = "Invalid file format. Please upload a CSV file."
      redirect_to root_path and return
    end

    @student_list_add = []
    CSV.foreach(uploaded_file.path, headers: true, header_converters: :symbol) do |row|
      @student_list_add << { name: row[:name]&.strip, role: row[:role]&.strip }
    rescue CSV::MalformedCSVError => e
      flash[:error] = "CSV file is malformed: #{e.message}"
      redirect_to root_path and return
    end

    if @student_list_add.empty?
      flash[:notice] = "CSV file is empty or not properly formatted."
      redirect_to root_path and return
    end

    render 'imported_data'
  end
end
