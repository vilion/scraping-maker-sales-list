# サイトにアクセスしgem
require 'csv'
require 'mechanize'
require 'pry'

agent = Mechanize.new
page = agent.get("https://www.wantedly.com/projects?type=mixed&page=1&company_tags%5B%5D=funded3k")

#corporate_number = row[1]
#corporate_number = "6140001005714"
#main_div = page.divs.find()

File.open("3000万円以上調達済みのスタートアップ、ベンチャー企業.csv", 'w') do |file|
  file.print("\xEF\xBB\xBF")  #bomを作成
  file.puts(['会社名', 'webサイト', '従業員数', '住所', '調達額', '設立年月'].to_csv)

  begin
    company_link_list = page.links.filter do |l|
      !l.href.nil? && l.href.include?("funded3k") && l.href.include?("filter_type") && l.href.include?("company_tags")
    end

    company_link_list.each do | link |
      co_page = link.click
      name = co_page.at_css("div.company-name").text.gsub("\n","")
      description_list = co_page.at("div.company-info-list").css("div.company-description").children
      start_year_month = description_list[3].text.gsub("\n","")
      member_count_elem = description_list.find {|e| e.text.include?("人のメンバー") }
      member_count = !member_count_elem.nil? ? member_count_elem.text.gsub("\n","") : "従業員数不明"
      address = description_list.last.text.gsub("\n","")
      website = description_list[1].attribute("href").value
      funded = description_list.find_all {|e| e.text.include?("資金") }.last.text.gsub("\n","").gsub(" /","")
      file.puts([name, website, member_count, address, funded, start_year_month].to_csv)
      file.flush()
    end

    next_link = page.links.find { |l| l.attribute("rel").value == "next" }
    page = !next_link.nil? ? next_link.click : nil

  end while !page.nil?

end



