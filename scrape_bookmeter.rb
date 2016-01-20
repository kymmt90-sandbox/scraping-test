require 'mechanize'
require 'nokogiri'

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

booklist_content = agent.get(BOOKLIST_URL).content.toutf8
booklist_doc = Nokogiri::HTML(booklist_content)
book_page_urls = []
book_names = []
booklist_doc.css('div.book_box_book_title > a').each do |node|
  book_page_urls << node.attribute('href').text
  book_names << node.text
end

dates = []
book_page_urls.each do |url|
  book_content = agent.get(ROOT_URL + url).content.toutf8
  book_doc = Nokogiri::HTML(book_content)
  year  = book_doc.at_css('select#read_date_y > option').attribute('value').text
  month = book_doc.at_css('select#read_date_m > option').attribute('value').text
  day   = book_doc.at_css('select#read_date_d > option').attribute('value').text
  dates << [year.to_s, month.to_s, day.to_s].join('/')
end

book_names.zip(dates) do |name_date|
  p name_date
end
