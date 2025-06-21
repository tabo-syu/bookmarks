# frozen_string_literal: true

module ApplicationHelper
  def contribution_graph_data(weeks: 53)
    end_date = Date.current
    start_date = end_date - (weeks * 7).days
    
    # Get all bookmarks created in the date range, grouped by date
    bookmark_counts = Bookmark
      .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
      .group("DATE(created_at)")
      .count
    
    # Generate array of dates with their counts
    (start_date..end_date).map do |date|
      count = bookmark_counts[date] || 0
      {
        date: date,
        count: count,
        level: contribution_level(count)
      }
    end
  end
  
  private
  
  def contribution_level(count)
    case count
    when 0
      0
    when 1..2
      1
    when 3..5
      2
    when 6..10
      3
    else
      4
    end
  end
end
