require 'yasuri'

ROOT_URL   = 'http://bookmeter.com'
USER_ID    = '104835'
LOGIN_URL  = "#{ROOT_URL}/login"
MYPAGE_URL = "#{ROOT_URL}/u/#{USER_ID}"
BOOKLIST_URL = "#{ROOT_URL}/u/#{USER_ID}/booklist" # 読んだ本

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

# 読んだ本リストに載っているすべての本情報の名前と URL 取得
BOOKLIST_NEXT_PAGE_XPATH = '//span[@class="now_page"]/following-sibling::span[1]/a'
root = Yasuri.pages_root BOOKLIST_NEXT_PAGE_XPATH do
  text_page_index '//span[@class="now_page"]/a'
  1.upto(24) do |i|
    send("text_book_#{i}_name", "//*[@id=\"main_left\"]/div/div[#{i + 1}]/div[2]/a")
    send("text_book_#{i}_link", "//*[@id=\"main_left\"]/div/div[#{i + 1}]/div[2]/a/@href")
  end
end

require 'json'
booklist_page = agent.get(BOOKLIST_URL)
jj root.inject(agent, booklist_page)
