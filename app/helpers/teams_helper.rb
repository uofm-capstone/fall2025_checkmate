module TeamsHelper


  include ClientSurveyPatternsHelper
  # Check any response for each team member
  def some_condition?(s, key)
    s[key] && s[key] != "Always" && s[key] != "Most of the time"
  end

  def render_cell(value, text = nil)
    classes = if value != "Always" && value != "Most of the time" then "text-white bg-danger" else "" end
    content = text ? "#{text} - #{value}" : value
    "<td class=\"#{classes}\">#{content}</td>".html_safe
  end

  def table_cell(s, question, negative_conditions = ["Always", "Most of the time"])
    css_class = negative_conditions.none? { |condition| s[question] == condition } ? "text-white bg-danger" : ""
    content_tag :td, s[question], class: css_class
  end

  def render_table(question_number, question_key)
    if @not_empty_questions.include?(question_number)
      content_tag :table, class: "table table-striped" do
        thead = content_tag :thead do
          content_tag :tr do
            content_tag :th do
              content_tag :p, @question_titles[question_key]
            end
          end
        end

        tbody = content_tag :tbody do
          @student_survey.map do |s|
            if s[question_key] != nil
              content_tag :tr do
                content_tag :td, "#{s[:q1]}: #{s[question_key]}"
              end
            end
          end.join.html_safe
        end

        thead + tbody
      end
    end
  end

  def render_client_table(question_number, question_key)
   # puts "DEBUG: @client_question_titles[question_key]: #{@client_question_titles[question_key]}"
    puts "DEBUG: render_client_table called for question #{question_number}"
    puts "DEBUG: @cliSurvey[0][question_key]: #{@cliSurvey[0][question_key]}"

    

    
      content_tag :table, class: "table table-striped" do
        thead = content_tag :thead do
          content_tag :tr do
            content_tag :th do
              content_tag :p, @client_question_titles[question_key] 
            end
          end
        end

        tbody = content_tag :tbody do
          content_tag :tr do
            content_tag :td, @cliSurvey[0][question_key] || 'N/A'
          end
        end

        thead + tbody
      end
  end
# New added 
  # def render_average_score(student_name, scores)
  #   if scores[:average_including_self]
  #     content_tag :p, "#{student_name}'s Average Score (Including Self): #{scores[:average_including_self].round(2)}"
  #   end
  #   if scores[:average_excluding_self]
  #     content_tag :p, "#{student_name}'s Average Score (Excluding Self): #{scores[:average_excluding_self].round(2)}"
  #   end
  # end

  
end

