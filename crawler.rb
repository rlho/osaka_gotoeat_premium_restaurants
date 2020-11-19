require 'open-uri'
require 'nokogiri'
require 'line_notify'

class TabelogTakeoutCrawler
  def execute
    comfort = Parse.new(site_name: '大阪キャンペーンプレミアム食事券')
    comfort.check_stock
  end
end

class Parse

  def initialize(site_name:)
    @start = ARGV[0].to_i
    @end = ARGV[1].to_i
    @site_name = site_name
    @pages = 808
  end

  def check_stock
    shop_names
    File.open("output_#{@start}_#{@end}_#{Date.today}.csv", 'w') do |f|
      f.puts("店名, 住所, 電話番号")
      shop_names.each do |shop_name|
        f.puts("#{shop_name[:shop_name]}, #{shop_name[:address]}, #{shop_name[:phone_number]}")
      end
    end
  end

  def doc(i)
    url = "https://premium-gift.jp/eatosaka/use_store?events=page&id=#{i}&store=&addr=&industry="
    Nokogiri.HTML(open(url))
  end

  def shop_names
    shops = []
    range = Range.new(@start,@end)
    range.each do |i|
      (1..21).each do |j|
        shop_xpath = "//div[@class='store-card__item'][#{j}]"
        shop_name = doc(i).xpath("#{shop_xpath}/h3[@class='store-card__title']").text
        address = doc(i).xpath("#{shop_xpath}/table[@class='store-card__table']/tbody/tr[1]/td").text
        phone_number = doc(i).xpath("#{shop_xpath}/table[@class='store-card__table']/tbody/tr[2]/td").text
        shops << {shop_name: shop_name, address: address, phone_number: phone_number }
      end
    end
    shops
  end
end


TabelogTakeoutCrawler.new.execute
