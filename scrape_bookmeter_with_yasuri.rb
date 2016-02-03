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

# 読んだ本リスト 1 ページ目に載っているすべての本情報への URL 取得
booklist_root = Yasuri.links_root '//*[@id="main_left"]/div//div[@class="book book_box_inline_3r"]/div[2]/a' do
  text_name '//*[@id="title"]'
  text_readers_count '//*[@id="side_left"]/div[1]/div/div[2]/div[3]/div/span', truncate: /^\d+/, proc: :to_i
end

require 'json'
booklist_page = agent.get(BOOKLIST_URL)
jj booklist_root.inject(agent, booklist_page)
