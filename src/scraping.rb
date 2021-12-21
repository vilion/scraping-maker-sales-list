# サイトにアクセスしgem
require 'csv'
require 'mechanize'
require 'pry'

agent = Mechanize.new
num_attempts = 0
begin
  num_attempts += 1
  page = agent.get("https://www.wantedly.com/projects?type=mixed&page=1&company_tags%5B%5D=funded3k")
rescue
  if num_attempts <= 10
    sleep 1
    retry
  else
    exit
  end
end

#corporate_number = row[1]
#corporate_number = "6140001005714"
#main_div = page.divs.find()

File.open("3000万円以上調達済みのスタートアップ、ベンチャー企業.csv", 'w') do |file|
  file.print("\xEF\xBB\xBF")  #bomを作成
  file.puts(['会社名', 'webサイト', '従業員数', '住所', '調達額', '設立年月'].to_csv)

  company_list = []

  page_count = 1
  begin
    company_link_list = page.links.filter do |l|
      !l.href.nil? && l.href.include?("funded3k") && l.href.include?("filter_type") && l.href.include?("company_tags")
    end

    company_link_list.each do | link |
      co_page = nil
      num_attempts = 0
      begin
        num_attempts += 1
        co_page = link.click
      rescue
        if num_attempts <= 10
          sleep 1
          retry
        else
          next
        end
      end
      
      name = co_page.at_css("div.company-name").text.gsub("\n","")

      next if company_list.include? name

      description_list = co_page.at("div.company-info-list").css("div.company-description").children
      year_month_elem = description_list.find {|e| e.text.include?("設立") }
      start_year_month = !year_month_elem.nil? ? year_month_elem.text.gsub("\n","") : "設立年月不明"
      member_count_elem = description_list.find {|e| e.text.include?("人のメンバー") }
      member_count = !member_count_elem.nil? ? member_count_elem.text.gsub("\n","") : "従業員数不明"
      address = description_list.last.text.gsub("\n","")
      website_link = !description_list[1].nil? ? description_list[1].attribute("href") : nil
      website = !website_link.nil? ? website_link.value : "サイト URL 不明"
      funded_elem = description_list.find_all {|e| e.text.include?("資金") }.last
      funded = !funded_elem.nil? ? funded_elem.text.gsub("\n","").gsub(" /","") : "調達金額不明"
      file.puts([name, website, member_count, address, funded, start_year_month].to_csv)
      file.flush()
      company_list.push name
    end
    page_count += 1

    num_attempts = 0
    begin
      num_attempts += 1
      page = agent.get("https://www.wantedly.com/projects?type=mixed&page=#{page_count}&company_tags%5B%5D=funded3k")
    rescue
      if num_attempts <= 1000
        sleep 1
        retry
      else
        page_count += 1
        num_attempts = 0
        retry
      end
    end
    #next_link = page.links.find { |l| l.rel? "next" }
    #page = !next_link.nil? ? next_link.click : nil

  end while !page.nil?

end



