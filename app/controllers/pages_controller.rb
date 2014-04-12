class PagesController < ApplicationController
  def hangout
    render "pages/hangout.xml.erb"
  end

  def hangout_view
    render "pages/_hangout_view.html.erb"
  end
end
