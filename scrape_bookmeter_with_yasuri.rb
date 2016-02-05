require 'yasuri'
require 'json'

ROOT_URL   = 'http://bookmeter.com'
USER_ID    = '104835'
LOGIN_URL  = "#{ROOT_URL}/login"
MYPAGE_URL = "#{ROOT_URL}/u/#{USER_ID}"
BOOKLIST_URL = "#{ROOT_URL}/u/#{USER_ID}/booklist" # 読んだ本
NUM_BOOKS_PER_PAGE = 40.freeze

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

# 読んだ本リスト 1 ページ目に載っている本 40 冊の名前と URL 取得
BOOKLIST_NEXT_PAGE_XPATH = '//span[@class="now_page"]/following-sibling::span[1]/a'.freeze
booklist_pages_root = Yasuri.pages_root BOOKLIST_NEXT_PAGE_XPATH, limit: 1 do
  text_page_index '//span[@class="now_page"]/a'
  1.upto(NUM_BOOKS_PER_PAGE) do |i|
    send("text_book_#{i}_name", "//*[@id=\"main_left\"]/div/div[#{i + 1}]/div[2]/a")
    send("text_book_#{i}_link", "//*[@id=\"main_left\"]/div/div[#{i + 1}]/div[2]/a/@href")
  end
end
booklist_first_page = agent.get(BOOKLIST_URL)
recent_40_books = booklist_pages_root.inject(agent, booklist_first_page)

# 直近に読んだ 40 冊の本の名前と読了日を取得
books_names_read_dates = []
recent_40_books.each do |page|
  1.upto(NUM_BOOKS_PER_PAGE) do |i|
    book_page = agent.get(ROOT_URL + page["book_#{i}_link"])
    book_page_date = Yasuri.struct_date '//*[@id="book_edit_area"]/form[1]/div[2]' do
      text_year '//*[@id="read_date_y"]/option[1]', truncate: /\d+/, proc: :to_i
      text_month '//*[@id="read_date_m"]/option[1]', truncate: /\d+/, proc: :to_i
      text_day '//*[@id="read_date_d"]/option[1]', truncate: /\d+/, proc: :to_i
    end
    book_name_read_date = { 'name' => page["book_#{i}_name"] }
    read_date = book_page_date.inject(agent, book_page)
    books_names_read_dates << book_name_read_date.merge(read_date)
  end
end
jj books_names_read_dates
