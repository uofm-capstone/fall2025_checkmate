module SprintsHelper

  def team_status_table(teams, sprint_list, flags)
    content_tag(:table, class: "table") do
      concat(content_tag(:thead) do
        content_tag(:tr) do
          concat(content_tag(:th, "Team", scope: "col"))
          concat(sprint_header(sprint_list))
        end
      end)
      concat(content_tag(:tbody) do
        team_rows(teams, sprint_list, flags)
      end)
    end
  end

  def sprint_header(sprint_list)
    sprint_list.map do |sprint|
      content_tag(:th, sprint, scope: "col")
    end.join.html_safe
  end

  def team_rows(teams, sprint_list, flags)
    rows = ''
    teams.each do |team|
      rows += "<tr><th>#{link_to(team, semester_team_path(@semester, team: team))}</th>"
      sprint_list.each do |sprint|
        rows += "<td>"
        if flags[sprint][team].include?("student blank")
          if unfinished_sprint(teams, flags, sprint)
            rows += icon_html("question-circle-fill.svg", "This sprint has not yet concluded")
          else
            rows += icon_html("exclamation-triangle-fill-red.svg", "All students failed to submit a survey")
          end
        elsif flags[sprint][team].empty?
          rows += icon_html("check-circle-fill.svg", "All is well")
        else
          flags[sprint][team].each do |flag|
            case flag
            when "missing submit"
              rows += icon_html("exclamation-triangle-fill-red.svg", "At least one of the students failed to submit a survey")
            when "low score"
              rows += icon_html("exclamation-triangle-fill-red.svg", "At least one of the students received an average rating lower than 4")
            when "no client score"
              rows += icon_html("exclamation-circle-fill-yellow.svg", "The client did not submit a survey")
            when "low client score"
              rows += icon_html("exclamation-triangle-fill-red.svg", "The client is unsatisfied")
            end
          end
        end
        rows += "</td>"
      end
      rows += "</tr>"
    end
    rows.html_safe
  end


  def icon_html(icon, title)
    "<div class='d-inline-flex p-2 m-0'><p class='p-0 m-0'>" +
      ActionController::Base.helpers.image_tag(icon, class: "", style: "height:16px", title: title) +
      "</p></div>"
  end


  def sprint_team_cells(teams, sprint_list, flags, current_team)
    sprint_list.map do |sprint|
      content_tag(:td) do
        content_tag(:div) do
          if flags[sprint][current_team].include?("student blank")
            icon, title = unfinished_sprint(teams, flags, sprint) ? ["question-circle-fill.svg", "This sprint has not yet concluded"] : ["exclamation-triangle-fill-red.svg", "All students failed to submit a survey"]
          elsif flags[sprint][current_team].empty?
            icon, title = ["check-circle-fill.svg", "All is well"]
          else
            icon, title = flag_icon_and_title(flags[sprint][current_team])
          end
          content_tag(:p, class: "p-0 m-0") do
            image_tag(icon, class: "", style: "height:16px", title: title)
          end
        end
      end
    end.join.html_safe
  end

  def flag_icon_and_title(flag)
    case flag
    when "student blank"
      return ["question-circle-fill.svg", "This sprint has not yet concluded"]
    when "all failed"
      return ["exclamation-triangle-fill-red.svg", "All students failed to submit a survey"]
    when "missing submit"
      return ["exclamation-triangle-fill-red.svg", "At least one of the students failed to submit a survey"]
    when "low score"
      return ["exclamation-triangle-fill-red.svg", "At least one of the students received an average rating lower than 4"]
    when "no client score"
      return ["exclamation-circle-fill-yellow.svg", "The client did not submit a survey"]
    when "low client score"
      return ["exclamation-triangle-fill-red.svg", "The client is unsatisfied"]
    when "all good"
      return ["check-circle-fill.svg", "All is well"]
    end
    ["", ""]
  end


  # def unfinished_sprint(teams, flags, sprint)
  #   # TODO: Add the implementation for this method
  # end
end
