# サイトにアクセスしgem
require 'csv'
require 'pry'

require 'bundler/setup'
require 'capybara/poltergeist'
Bundler.require

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {inspector: true, js_errors: true, timeout: 1000, phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any']})
end
session = Capybara::Session.new(:poltergeist)

#count = 0

(1..47).each do | pref_index |
  begin
    session.visit "https://etsuran.mlit.go.jp/TAKKEN/chintaiKensaku.do"
  rescue Net::HTTPForbidden
    sleep 1
    retry
    #puts “  caught Excepcion !”
    #next
    #try_count += 1
    #retry if try_count != 5 # 上手くアクセスできないときはもう1回！
  rescue Exception => e
    sleep 1
    retry
    #puts “  caught Excepcion !”
    #next
    #next if try_count == 4
    #try_count += 1
  end

  select_pref = session.find("select#kenCode")
  option_list = select_pref.find_all("option")
  option = option_list[pref_index]
  pref = option.text[3..]
  option.select_option

  select = session.find("select#sortValue")
  select.find("option[value='4']").select_option
  select_count = session.find("select#dispCount")
  select_count.find("option[value='50']").select_option

  search_btn = session.find("img[src='/TAKKEN/images/btn_search_off.png']")
  search_btn.click

  File.open("./product-list/不動産管理会社/#{pref}内の不動産管理会社のリスト.csv", 'w') do |file|
    company_name_list = []
    file.print("\xEF\xBB\xBF")  #bomを作成
    file.puts(['会社名', '会社名フリガナ', '住所', '郵便番号', '電話番号', '代表氏名', '代表氏名フリガナ', '登録番号'].to_csv)

    try_count = 0
    loop do
      result_table = nil
      begin
        result_table = session.find("table.re_disp")
      rescue
        retry
      end
      link_list = result_table.find_all("a")
      size = link_list.size
      (0..size-1).each do | index |
        begin
          result_table = session.find("table.re_disp")
          link_list = result_table.find_all("a")
          link = link_list[index]
          if company_name_list.include? link.text
            next
          end

          link.trigger("click")
          while !session.current_url.include? 'ctGaiyo.do'
            sleep 1
          end
          nokogiri_html = Nokogiri.make(session.html)
          company_name_header = nokogiri_html.at_css("th:contains('商号又は名称')")
          company_name = company_name_header.next_sibling.next_sibling.children[1].text
          company_name_pron = company_name_header.next_sibling.next_sibling.children[0].text
          owner_name_header = nokogiri_html.at_css("th:contains('代表者の氏名')")
          owner_name = owner_name_header.next_sibling.next_sibling.children[1].text
          owner_name_pron = owner_name_header.next_sibling.next_sibling.children[0].text
          address_header = nokogiri_html.at_css("th:contains('主たる事務所の所在地')")
          postal_code = address_header.next_sibling.next_sibling.children[0].text
          address = address_header.next_sibling.next_sibling.children[2].text
          tel_header = nokogiri_html.at_css("th:contains('電話番号')")
          tel_no = tel_header.next_sibling.next_sibling.text
          regitration_number_header = nokogiri_html.at_css("th:contains('登録番号')")
          registration_number = regitration_number_header.next_sibling.next_sibling.text
          file.puts([company_name, company_name_pron, address, postal_code, tel_no, owner_name, owner_name_pron, registration_number].to_csv)
          file.flush()
          company_name_list.push(company_name)
          session.go_back
        rescue => e
          puts e.to_s
        end
      end

      next_btn = nil
      btn_obtain_count = 0
      begin
        next_btn_list = session.find_all("img[src='/TAKKEN/images/result_move_r.jpg']")
        next_btn = next_btn_list.first
        btn_obtain_count += 1
      end while next_btn.nil? && btn_obtain_count < 10

      break if next_btn.nil? || next_btn["onclick"] == ""
      next_btn.click
    end

  end
end
