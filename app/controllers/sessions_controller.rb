class SessionsController < ApplicationController
  def clear_session
    cookies.permanent[:session] = nil
    cookies.permanent[:welcome] = nil
    flash[:message] = 'All cookies cleared.'
    redirect_to welcome_path
  end

  def log
    session = get_session
    session.update_attribute(:completed_to, params[:time])
    return redirect_to :back
  end

  def add_source
    return redirect_to :back unless SOURCES.include?(params[:source])
    get_session.update_sources(params[:source])
    return redirect_to :back
  end

  def share
    session = get_session
    path = root_path + session.identifier
    flash[:message] = "Visit <a href=\"#{path}\">this link</a> on other devices to sync your read status &amp; settings"
    redirect_to path
  end

  def add_trello_story
    item = Item.find(params[:id])
    session = get_session
    TrelloClient.new(session.trello_token, session.trello_username).add_item(
      title: item.title,
      description: [
        item.url,
        ((item.comment_url?)? "Comments:\n#{item.comment_url}" : ''),
        "via #{item.source.humanize.capitalize}",
        "Saved: #{Time.zone.now} - Posted: #{item.created_at}"
      ].join("\n\n")
    )
    session.update_attribute(:saved_items, session.saved_items + [item.id])
    return redirect_to request.env["HTTP_REFERER"] + "/##{item.short_title}" if request.env["HTTP_REFERER"]
    return redirect_to all_path + "/##{item.short_title}"
  end

  def trello
    if params[:token] && params[:token].length == 64
      get_session.update_attribute(:trello_token, params[:token])
      tc = TrelloClient.new(params[:token])
      get_session.update_attribute(:trello_username, tc.fetch_username)
      tc.add_item({title: 'Welcome to serializer on Trello!'})
    elsif params[:token]
      flash[:message] = 'Please check that token.'
    end
    @session = get_session
  end
end
