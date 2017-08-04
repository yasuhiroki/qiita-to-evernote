require 'qiita'
require 'qiita-markdown'

class Qiita2Evernote::Client::Qiita
  attr_reader :client

  def initialize(access_token)
    @client ||= ::Qiita::Client.new(access_token: access_token)
  end

  def stock_items(qiita_id)
    return @items if @items

    id = qiita_id

    per_page = 100
    stocks_first = @client.list_user_stocks(id, per_page: per_page)
    stocks_page_num = stocks_first.headers["Total-Count"].to_i / per_page + 1

    @stocks = {
      1 => stocks_first.body
    }
    (2..stocks_page_num).each do |i|
      @stocks[i] = @client.list_user_stocks(id, per_page: per_page, page: i).body
    end
    @items = @stocks.map { |_, items| items}.flatten

    return @items
  end

  def qiita_markdown
    @processor ||= ::Qiita::Markdown::Processor.new
  end
end

