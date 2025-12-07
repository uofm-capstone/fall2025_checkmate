#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "dotenv"
Dotenv.load(".env.development")

require_relative "../config/environment"

service = GithubService.new

if false
  repo       = "uofm-capstone/fall2025_checkmate"
  username   = "JacobHensley"
  start_date = Date.new(2025, 11, 5).to_time # Inclusive
  end_date   = Date.new(2025, 11, 12).to_time # Exclusive

  result = service.get_commit_info(repo, username, start_date, end_date)

  puts "Commit Count:        #{result.commit_count}"
  puts "Lines Added:         #{result.lines_added}"
  puts "Lines Removed:       #{result.lines_removed}"
  puts "Total Lines Changed: #{result.lines_changed}"
end

if false
  for i in 40..40 do
    s = "https://github.com/orgs/uofm-capstone/projects/#{i}/views/1"
    puts "Calling project_cards with: #{s.inspect}"
    cards = service.project_cards(s)
    puts cards
  end
end