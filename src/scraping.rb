# サイトにアクセスしgem
require 'csv'
require 'mechanize'
require 'pry'

agent = Mechanize.new
agent.user_agent_alias = "Windows Mozilla"

# 法人検索から forbidden orz
code_name_map = {
  "19": "武器製造業", "20": "食料品・飼料・飲料製造業", "21": "たばこ製造業", "22": "繊維工業（衣服,その他の繊維製品を除く）", "22": "繊維工業（衣服,その他の繊維製品を除く）",
  "23": "衣服・その他の繊維製品製造業", "24": "木材・木製品製造業（家具を除く）", "25": "家具・装備品製造業", "26": "パルプ・紙・紙加工品製造業", "27": "出版・印刷・同関連産業",
  "28": "化学工業", "29": "石油製品・石炭製品製造業", "30": "ゴム製品製造業", "31": "皮革・同製品・毛皮製造業", "32": "窯業・土石製品製造業", "33": "鉄鋼業,非鉄金属製造業",
  "34": "金属製品製造業", "35": "一般機械器具製造業", "36": "電気機械器具製造業", "37": "輸送用機械器具製造業", "38": "精密機械・医療機械器具製造業", "39": "その他の製造業"
}


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
#  "20522" => "単体飼料製造業", "20523" => "有機質飼料製造業", "20601" => "砂糖製造業（砂糖精製業を除く）", "20602" => "砂糖精製業", "20701" => "パン製造業",
#  "20702" => "生菓子製造業", "20703" => "ビスケット類・干菓子製造業", "20704" => "米菓製造業", "20709" => "その他のパン・菓子製造業",
#  "20811" => "果実酒製造業", "20812" => "ビール製造業", "20813" => "清酒製造業", "20814" => "蒸留酒・混成酒製造業", "20821" => "清涼飲料製造業",
#  "20911" => "植物油脂製造業", "20912" => "動物油脂製造業", "20913" => "食用油脂加工業", "20921" => "ぶどう糖・水あめ・異性化糖製造業", "20931" => "製氷業",
#  "20941" => "冷凍調理食品製造業", "20951" => "めん類製造業", "20991" => "ふくらし粉・イースト・その他の酵母剤製造業", "20992" => "でんぷん製造業",
#  "20993" => "こうじ・種こうじ・麦芽製造業", "20994" => "豆腐・油揚製造業", "20995" => "あん類製造業製造業", "20996" => "そう（惣）菜製造業",
#  "20997" => "製茶業", "20998" => "コーヒー製造業", "20999" => "他に分類されない食料品製造業", "21101" => "たばこ製造業", "21102" => "葉たばこ製造業",
#  "22101" => "器械生糸製造業", "22102" => "座繰生糸製造業", "22103" => "玉系製造業", "22109" => "その他の生糸製造業", "22211" => "綿紡績業", "22212" => "化学繊維紡績業",
#  "22221" => "毛紡績業", "22231" => "絹紡績業", "22241" => "麻紡績業", "22299" => "その他の紡績業", "22311" => "綿・スフ織物業", "22312" => "絹・人絹織物業",
#  "22331" => "毛織物業", "22341" => "麻織物業", "22399" => "その他の織物業", "22411" => "刺しゅうレース製造業", "22412" => "編レース製造業", "22413" => "ボビンレース製造業",
#  "22421" => "組ひも製造業", "22422" => "細幅織物業", "22429" => "その他のレース・繊維雑品製造業", "22501" => "丸編ニット生地製造業", "22502" => "たて編ニット生地製造業",
#  "22503" => "横編ニット生地製造業", "22601" => "綿・スフ・麻織物機械染色業", "22602" => "絹・人絹織物機械染色業", "22603" => "毛織物機械染色整理業", "22604" => "織物整理業",
#  "22605" => "織物手加工染色整理業", "22606" => "綿状繊維・系染色整理業", "22607" => "ニット・レース染色整理業", "22608" => "繊維雑品染色整理業", "22701" => "ねん系製造業（かさ高加工糸製造業を除く）",
#  "22702" => "かさ高加工糸製造業", "22801" => "網製造業", "22802" => "魚網製造業", "22809" => "その他の網地製造業", "22911" => "フェルト・不識布製造業", "22921" => "じゅうたん・その他の繊維性床敷物製造業",
#  "22931" => "製綿業", "22941" => "整毛業", "22951" => "上塗りした織物・防水した織物製造業", "22971" => "繊維製衛生材料製造業", "22991" => "麻製繊業", "22992" => "せん（剪）毛業",
#  "22999" => "他に分類されない繊維工業", "23101" => "成人男子・少年服製造業", "23201" => "事務用・作業用・衛生用・スポーツ用衣服製造業（ニット製を除く）", "23202" => "学校服製造業（ニット製を除く）",
#  "23203" => "ニット製事務用・作業用・スポーツ用衣服・学校服製造業(アウターシャツ類を除く)", "23301" => "成人女子・少女服製造業", "23302" => "乳幼児服製造業", "23401" => "シャツ製造業（下着を除く）",
#  "23402" => "セーター類製造業", "23403" => "織物製下着製造業", "23404" => "織物製寝着類製造業", "23405" => "ニット製下着製造業", "23406" => "ニット製寝着製造業", "23407" => "補整着製造業",
#  "23408" => "ニット製アウターシャツ類製造業", "23501" => "帽子製造業（帽体を含む）", "23701" => "毛皮製衣服・身の回り品製造業", "23801" => "和装製品製造業", "23802" => "足袋製造業", "23803" => "靴下製造業",
#  "23804" => "ネクタイ製造業", "23805" => "スカーフ・マフラー製造業", "23806" => "ハンカチーフ製造業", "23807" => "手袋製造業", "23808" => "ニット製外衣（アウターシャツ類,セーター類などを除く）製造業",
#  "23809" => "他に分類されない衣服・繊維製身の回り品製造業", "23911" => "寝具製造業", "23921" => "帆布製品製造業", "23922" => "繊維性袋製造業", "23991" => "刺しゅう業", "23992" => "タオル製造業",
#  "23999" => "他に製造業", "24111" => "一般製材業", "24112" => "床板製造業", "24121" => "屋根板製造業", "24122" => "経木・同製品製造業（折箱,マッチ箱を除く）", "24123" => "木毛製造業",
#  "24124" => "たる・おけ材製造業", "24125" => "木材チップ製造業", "24129" => "他に分類されない特殊製材業", "24131" => "単板（ベニヤ板）製造業", "24211" => "合板製造業", "24221" => "造作材製造業（建具を除く）",
#  "24222" => "建築用木製組立材料製造業", "24223" => "パーティクルボード製造業", "24224" => "銘板・銘木製造業", "24301" => "竹・とう・きりゅう等陽気製造業", "24302" => "折箱製造業",
#  "24303" => "木箱製造業(折箱を除く)", "24304" => "和たる製造業", "24305" => "洋たる製造業", "24306" => "おけ製造業", "24401" => "木製履物製造業", "24901" => "木材薬品処理業",
#  "24902" => "靴型等製造業", "24903" => "曲輪・曲物製造業", "24909" => "他に分類されない木製品製造業（竹,とうを含む）", "25111" => "木製家具製造業（漆塗りを除く）", "25121" => "金属製家具製造業",
#  "25131" => "マットレス・組スプリング製造業", "25201" => "宗教用具製造業", "25301" => "建具製造業", "25911" => "事務所用・店舗用装備品製造業", "25991" => "窓用・扉用日よけ製造業",
#  "25992" => "日本びょうぶ・衣こう・すだれ製造業", "25993" => "鏡縁・額縁製造業", "25999" => "他に分類されない家具・装備品製造業", "26111" => "溶解パルプ製造業", "26112" => "製紙パルプ製造業",
#  "26121" => "洋紙製造業", "26131" => "板紙製造業", "26141" => "機械すき和紙製造業", "26151" => "手すき和紙製造業", "26201" => "塗工紙製造業", "26202" => "段ボール製造業", "26203" => "壁紙・ふすま紙製造業",
#
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

    page = nil
    try_count = 0
    begin
      page = agent.get("https://unisonas.com/search.php")
    rescue Mechanize::ResponseCodeError => e
     case e.response_code
      when “404”
        puts “  caught Net::HTTPNotFound !”
        next # ページが見付からないときは次へ
      when “502”
        puts “  caught Net::HTTPBadGateway !”
        next
        #next if try_count == 4
        #try_count += 1
        #retry # 上手くアクセスできないときはもう1回！
      else
        puts “  caught Excepcion !” + e.response_code
        next
        #next if try_count == 4
        #try_count += 1
        #retry
      end
    rescue  Net::HTTPInternalError      
      puts “  caught Excepcion !”
      next
      #next if try_count == 4
      #try_count += 1
      #retry
    rescue Net::HTTPForbidden
      puts “  caught Excepcion !”
      next
      #try_count += 1
      #retry if try_count != 5 # 上手くアクセスできないときはもう1回！
    rescue Exception
      puts “  caught Excepcion !”
      next
      #next if try_count == 4
      #try_count += 1
      #retry
    end
    next if page.nil?

    hyogo_title = page.at_css("h3.title:contains('兵庫県')")
    detail_root = hyogo_title.parent.next_sibling.next_sibling.next_sibling.next_sibling
    city_link = detail_root.at_css("a:contains('#{city}')")
    next if city_link.nil?
    city_page = nil
    try_count = 0
    begin
      city_page = agent.get("https://unisonas.com/#{city_link.attributes["href"].value}")
    rescue Mechanize::ResponseCodeError => e
     case e.response_code
      when “404”
        puts “  caught Net::HTTPNotFound !”
        next # ページが見付からないときは次へ
      when “502”
        puts “  caught Net::HTTPBadGateway !”
        next
        #next if try_count == 4
        #try_count += 1
        #retry # 上手くアクセスできないときはもう1回！
      else
        puts “  caught Excepcion !” + e.response_code
        next
        #next if try_count == 4
        #try_count += 1
        #retry
      end
    rescue  Net::HTTPInternalError      
      puts “  caught Excepcion !”
      next
      #try_count += 1
      #retry if try_count != 5 # 上手くアクセスできないときはもう1回！
    rescue Net::HTTPForbidden
      puts “  caught Excepcion !”
      next
      #try_count += 1
      #retry if try_count != 5 # 上手くアクセスできないときはもう1回！
    rescue Exception
      puts “  caught Excepcion !”
      next
      #next if try_count == 4
      #try_count += 1
      #retry
    end

    next if city_page.nil?
    corporate_link = city_page.at_css("a:contains('#{corporate_name}')")
    next if corporate_link.nil?

    uni_page = nil
    try_count = 0
    begin
      uni_page = agent.get("https://unisonas.com/#{corporate_link.attributes["href"].value[3..]}")
    rescue Mechanize::ResponseCodeError => e
     case e.response_code
      when “404”
        puts “  caught Net::HTTPNotFound !”
        next # ページが見付からないときは次へ
      when “502”
        puts “  caught Net::HTTPBadGateway !”
        next
        #next if try_count == 4
        #try_count += 1
        #retry # 上手くアクセスできないときはもう1回！
      else
        puts “  caught Excepcion !” + e.response_code
        next
        #next if try_count == 4
        #try_count += 1
        #retry
      end
    rescue Net::HTTPInternalError      
      puts “  caught Excepcion !”
      next
      #try_count += 1
      #retry if try_count != 5 # 上手くアクセスできないときはもう1回！
    rescue Net::HTTPForbidden
      puts “  caught Excepcion !”
      next
      #try_count += 1
      #retry if try_count != 5 # 上手くアクセスできないときはもう1回！
    rescue Exception
      puts “  caught Excepcion !”
      next
      #next if try_count == 4
      #try_count += 1
      #retry
    end

    next if uni_page.nil?

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

    category = code_name_map[code_elem.text[0..1]]

    address_header = table_element.at_css("th:contains('所在地')")
    address = address_header.nil? ? "" : address_header.next_sibling.text 
    telno_header = table_element.at_css("th:contains('電話番号')")
    tel_no = telno_header.nil? ? "" : telno_header.next_sibling.text 
    capital_header = table_element.at_css("th:contains('資本金')")
    capital = capital_header.nil? ? "" : capital_header.next_sibling.text 
    representative_header = table_element.at_css("th:contains('代表者')")
    representative = representative_header.nil? ? "" : representative_header.next_sibling.text 

    file.puts([corporate_name, corporate_number, category, address, tel_no, capital, representative].to_csv)

    #count += 1

    #if count == 15
    #  break
    #end

  end
end
