require 'mechanize'

ROOT_URL   = 'http://bookmeter.com'
USER_ID    = '104835'
LOGIN_URL  = "#{ROOT_URL}/login"
MYPAGE_URL = "#{ROOT_URL}/u/#{USER_ID}"
BOOKLIST_URL = "#{ROOT_URL}/u/#{USER_ID}/booklist"

if ARGV.size < 2
  warn 'need mail and password'
  exit 1
end

MAIL = ARGV[0]
PASSWORD = ARGV[1]

agent = Mechanize.new do |a|
  a.user_agent_alias = 'Mac Safari'
end

agent.get(LOGIN_URL) do |page|
  page.form_with(action: '/login') do |form|
    form.field_with(name: 'mail').value = MAIL
    form.field_with(name: 'password').value = PASSWORD
  end.submit
end

book_page_urls = []
agent.get(BOOKLIST_URL).search('div.book_box_book_title > a').each do |node|
  book_page_urls << node.attribute('href').text
end

Book = Struct.new(:name, :completion_date)

books = []
book_page_urls.each do |url|
  book_page = agent.get(ROOT_URL + url)

  name = book_page.search('h1').first.text
  date = %w|y m d|.map do |symbol|
    book_page.search("select#read_date_#{symbol} > option").first.attribute('value').text
  end.join('/')

  books << Book.new(name, date)
end

books.each { |book| puts "#{book[:name]}: #{book[:completion_date]}" }
