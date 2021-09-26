# サイトにアクセスしgem
require 'csv'
require 'mechanize'
require 'pry'

url = 'https://tdb.smrj.go.jp/corpinfo/corporate/search#o'

agent = Mechanize.new
page = agent.get(url)

CSV.foreach("corporate-number-list/28_hyogo_all_20210831.csv") do |row|
  corporate_number = row[1]
  form = page.form_with(id: 'corpSearchForm_id' )
  form.corporateNumber = corporate_number
  result = agent.send(form)
end
