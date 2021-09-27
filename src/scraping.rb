# サイトにアクセスしgem
require 'csv'
require 'mechanize'
require 'pry'

agent = Mechanize.new
#page = agent.get("http://splash:8050/render.html?url=https://google.co.jp&wait=0.5")

#CSV.foreach("corporate-number-list/28_hyogo_all_20210831.csv") do |row|
  #corporate_number = row[1]
  corporate_number = "6140001005714"
  #form = page.forms[0]
  #form.ie = "utf-8"
  #form.q = "#{corporate_number} site:unisonas.com"
  #form.q = "6140001005714 site:unisonas.com"
  #form.q = "神戸製鋼 site:unisonas.com"
  unisonal_result = agent.get("http://splash:8050/render.html?url=https://www.google.com/search?q=#{corporate_number}+%3Asite:unisonas.com")
  #unisonal_result = agent.submit(form)
  link = unisonal_result.links.find { |l| l.text.include?("UNISONAS")  }
  binding.pry
  #next if link.nil?
  binding.pry
  uni_page = link.click
  table_element = uni_page.at('table.statsDay')
  code_header = table_element.at_css("th:contains('産業分類主業コード')")
  #next if code_header.nil?
  code_elem = code_header.next_sibling
  main_code = code_elem.text[0..1].to_i
  binding.pry
  #next unless 19 <= main_code && main_code <= 39
  
  #form.q = row[6]
  #company_name = row[6]
  company_name = "株式会社神戸製鋼所"
  #search_result = agent.submit(form)
  search_result = agent.get("http://splash:8050/render.html?url=https://www.google.co.jp/search?q=#{company_name}")
  site_link = search_result.links.find { |l| l.text.include?("ウェブサイト")  }

  official_url = ""
  unless site_link.nil?
    site = site_link.click
    official_url = site.uri.to_s
  end

  address = table_element.at_css("th:contains('所在地')").next_sibling.text
  tel_no = table_element.at_css("th:contains('電話番号')").next_sibling.text

#end
