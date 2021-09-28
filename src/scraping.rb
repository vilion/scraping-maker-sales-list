# サイトにアクセスしgem
require 'csv'
require 'mechanize'
require 'pry'

agent = Mechanize.new

# 法人検索があるため不要 orz
#code_name_map = {
#  "19101" => "銃製造業", "19201" => "砲製造業", "19301" => "銃弾製造業",
#  "19401" => "砲弾弾体製造業", "19402" => "薬莢製造業", "19403" => "火薬類の入っていない武器用信管製造業",
#  "19501" => "銃砲弾以外の弾薬外殻製造業", "19502" => "銃砲弾以外の関連機械器具製造業（装填組立業を除く）", "19601" => "弾薬装てん組立業（銃弾製造業を除く）",
#  "19701" => "特殊走行車両・同部分品製造業", "19901" => "弾薬投射機械器具製造業（銃、砲を除く）", "19909" => "他に分類されない武器製造業",
#  "20111" => "肉製品製造業", "20121" => "乳製品製造業", "20199" => "その他の畜産食料品製造業",
#  "20201" => "水産缶詰・瓶詰製造業", "20201" => "海藻加工業", "20203" => "寒天製造業", "20204" => "魚肉ハム・ソーセージ製造業", "20205" => "水産練製品製造業",
#  "20206" => "冷凍・水産物製造業", "20207" => "冷凍水産食品製造業", "20209" => "その他の水産食料品製造業", "20301" => "野菜缶詰・果実缶詰・農産保存食料品製造業（野菜漬物を除く）",
#  "20302" => "野菜漬物製造業（缶詰,瓶詰,つぼ詰を除く）", "20401" => "味そ製造業", "20402" => "しょう油・食用アミノ酸製造業",
#  "20403" => "化学調味料製造業", "20404" => "ソース製造業", "20405" => "食酢製造業", "20409" => "その他の調味料製造業",
#  "20511" => "精米業", "20512" => "精麦業", "20513" => "小麦粉製造業", "20519" => "その他の精穀・製粉業", "20521" => "配合飼料製造業",
#  "20522" => "単体飼料製造業", "20523" => "有機質飼料製造業", "20601" => "小麦粉製造業", "20519" => "その他の精穀・製粉業", "20521" => "配合飼料製造業",
#
#
#
#  "39611" => "プラスチックフィルム製造業",
#
#}

count = 0
File.open("兵庫県内の製造業の会社リスト.csv", 'w') do |file|
  file.print("\xEF\xBB\xBF")  #bomを作成
  file.puts(['会社名', '法人番号', '業種', '住所', '電話番号', '資本金', '代表氏名'].to_csv)

  CSV.foreach("corporate-number-list/28_hyogo_all_20210831.csv").with_index(1) do |row, ln|
    corporate_number = row[1]
    city = row[10]
    corporate_name = row[6]

    #corporate_number = "6140001005714"
    #city = "神戸市中央区"
    #corporate_name = "株式会社神戸製鋼所"
    page = agent.get("https://unisonas.com/search.php")
    hyogo_title = page.at_css("h3.title:contains('兵庫県')")
    detail_root = hyogo_title.parent.next_sibling.next_sibling.next_sibling.next_sibling
    city_link = detail_root.at_css("a:contains('#{city}')")
    city_page = agent.get("https://unisonas.com/#{city_link.attributes["href"].value}")
    corporate_link = city_page.at_css("a:contains('#{corporate_name}')")
    next if corporate_link.nil?
    uni_page = agent.get("https://unisonas.com/#{corporate_link.attributes["href"].value[3..]}")

    # ユニゾナス 詳細ページ以降
    table_element = uni_page.at('table.statsDay')
    code_header = table_element.at_css("th:contains('産業分類主業コード')")
    next if code_header.nil?
    code_elem = code_header.next_sibling
    main_code = code_elem.text[0..1].to_i
    next unless 19 <= main_code && main_code <= 39
    
    # URL 取得。要 google 課金
    #form.q = row[6]
    #form.q = "神戸製鋼 site:unisonas.com"
    #search_result = agent.submit(form)
    #site_link = search_result.links.find { |l| l.text.include?("ウェブサイト")  }
    #site = site_link.click

    #official_url = site.uri.to_s

    # 業種取得 中小企業なんちゃらの法人検索
    category_search_page = agent.get("https://tdb.smrj.go.jp/corpinfo/corporate/search#o")
    search_form = category_search_page.form_with(id: 'corpSearchForm_id')
    search_form.radiobutton_with(name: 'searchMethod').value = "1"
    search_form.corporateNumber = corporate_number
    result_page = agent.submit(search_form)
    result_form = result_page.form_with(action: "/corpinfo/corporate/search")
    result_csrf = result_form.field_with(id: "csrfToken_id").value
    node = {}
    # Create a fake form
    class << node
      def search(*args); []; end
    end
    node["method"] = "POST"
    #node["enctype"] = "application/x-www-form-urlencoded"
    node["id"] = "openPage"
    node["name"] = "pageForm"
    fake_form = Mechanize::Form.new(node)
    fake_form.fields << Mechanize::Form::Field.new({"type" => "hidden", "name" => "corpnum"}, corporate_number)
    fake_form.fields << Mechanize::Form::Field.new({"type" => "hidden", "id" => "csrfToken_id", "name" => "_csrf"}, result_csrf)
    fake_form.fields << Mechanize::Form::Field.new({"type" => "hidden", "name" => "no-login"}, "")
    fake_form.action = "/corpinfo/corporate/detail"
    detail_page = agent.submit(fake_form)

    category = detail_page.at_css("dt:contains('業種１')").next_sibling.next_sibling.text
    category2 = detail_page.at_css("dt:contains('業種２')").next_sibling.next_sibling.text
    category = category + ", " + category2 unless category2 == "-"
    category3 = detail_page.at_css("dt:contains('業種３')").next_sibling.next_sibling.text
    category = category + ", " + category3 unless category3 == "-"

    address_header = table_element.at_css("th:contains('所在地')")
    address = address_header.nil? ? "" : address_header.next_sibling.text 
    telno_header = table_element.at_css("th:contains('電話番号')")
    tel_no = telno_header.nil? ? "" : telno_header.next_sibling.text 
    capital_header = table_element.at_css("th:contains('資本金')")
    capital = capital_header.nil? ? "" : capital_header.next_sibling.text 
    representative_header = table_element.at_css("th:contains('代表者')")
    representative = representative_header.nil? ? "" : representative_header.next_sibling.text 

    file.puts([corporate_name, corporate_number, category, address, tel_no, capital, representative].to_csv)

    count += 1

    if count == 30
      break
    end

  end
end
