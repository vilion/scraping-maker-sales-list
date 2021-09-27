# サイトにアクセスしgem
require 'csv'
require 'mechanize'
require 'pry'

agent = Mechanize.new
page = agent.get("https://unisonas.com/search.php")

code_name_map = {
  "19101" => "銃製造業", "19201" => "砲製造業", "19301" => "銃弾製造業",
  "19401" => "砲弾弾体製造業", "19402" => "薬莢製造業", "19403" => "火薬類の入っていない武器用信管製造業",
  "19501" => "銃砲弾以外の弾薬外殻製造業", "19402" => "薬莢製造業", "19403" => "火薬類の入っていない武器用信管製造業",


  "39611" => "プラスチックフィルム製造業",

}

CSV.foreach("corporate-number-list/28_hyogo_all_20210831.csv") do |row|
  corporate_number = row[1]
  city = row[10]
  corporate_name = row[6]

  #corporate_number = "6140001005714"
  #city = "神戸市中央区"
  #corporate_name = "株式会社神戸製鋼所"

  hyogo_title = page.at_css("h3.title:contains('兵庫県')")
  detail_root = hyogo_title.parent.next_sibling.next_sibling.next_sibling.next_sibling
  city_link = detail_root.at_css("a:contains('#{city}')")
  city_page = agent.get("https://unisonas.com/#{city_link.attributes["href"].value}")
  corporate_link = city_page.at_css("a:contains('#{corporate_name}')")
  next if corporate_link.nil?
  uni_page = agent.get("https://unisonas.com/#{corporate_link.attributes["href"].value[3..]}")

  # 詳細ページ以降
  table_element = uni_page.at('table.statsDay')
  code_header = table_element.at_css("th:contains('産業分類主業コード')")
  next if code_header.nil?
  code_elem = code_header.next_sibling
  main_code = code_elem.text[0..1].to_i
  next unless 19 <= main_code && main_code <= 39
  
  #form.q = row[6]
  #form.q = "神戸製鋼 site:unisonas.com"
  #search_result = agent.submit(form)
  #site_link = search_result.links.find { |l| l.text.include?("ウェブサイト")  }
  #site = site_link.click

  #official_url = site.uri.to_s
  address = table_element.at_css("th:contains('所在地')").next_sibling.text
  tel_no = table_element.at_css("th:contains('電話番号')").next_sibling.text
  capital = table_element.at_css("th:contains('資本金')").next_sibling.text
  representative = table_element.at_css("th:contains('代表者')").next_sibling.text
  category = code_name_map[table_element.at_css("th:contains('産業分類主業コード')").next_sibling.text]

end
