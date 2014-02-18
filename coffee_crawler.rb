require 'mechanize'
require './coffee_seller'
require './address'
require './proxy'

class CoffeeCrawler

  CSV_HEADER = "Product,Source,Price,Qty,Unit,Low,High,Avg Price USD,MOQ,MOQ,Supply capacity,Ability,Seller,Seller Profile Url, Seller company contact url, Phone No,Mobile,Address,Zip,Country,State,City,Website,Raw Address"

  attr_accessor :start_url, :pagination_url, :page_count, :agent, :extracted_data, :proxy

  def initialize(start_url="http://www.alibaba.com/products/F0/Coffee_beans.html", pagination_url="http://www.alibaba.com/products/F0/Coffee_beans/##number##.html")
    @start_url = start_url
    @pagination_url = pagination_url
    @extracted_data = []
    @proxy = Proxy.new
  end

  def crawl
    prepare_csv_file
    current_page = @proxy.page_with_proxy(@start_url)
    @page_count = extract_maximum_page_count_from current_page
    extract_info_for(current_page)
    save_data_in_csv
    (2..@page_count).each do |page_number|
      url = page_url_for_number(page_number)
      puts url
      extract_info_for(@proxy.page_with_proxy(url))
      save_data_in_csv
    end
  end

  private

  def prepare_csv_file
    output_file = File.open("./coffee_output.csv", "w")
    output_file.write(CSV_HEADER)
    output_file.write("\n")
    output_file.close
  end

  def save_data_in_csv
    output_file = File.open("./coffee_output.csv", "a")
    @extracted_data.each do |record|
      output_file.write(record.to_csv_record)
      output_file.write("\n")
    end
    output_file.close
    @extracted_data = []
  end

  def extract_info_for page
    items = page.search(".ls-item")
    record_count = items.count
    @extracted_data += (0..record_count-1).collect do |record_num|
      item_content = items[record_num]
      product_name = extract_title_from item_content
      product_detail_url = extract_url_from item_content
      attributes = extract_attributes_from item_content
      properties = extract_properties_from item_content
      seller_name = seller_name_from item_content
      seller_profile_url = seller_profile_url item_content
      company_profile_url = extract_company_profile_url item_content
      address = extract_seller_address company_profile_url
      CoffeeSeller.new(seller_name, product_name, attributes, properties, product_detail_url, seller_profile_url, company_profile_url, "", address)
    end
  end

  def extract_seller_address profile_url
    puts "Extracting info for #{profile_url}"
    profile_page = @proxy.page_with_proxy(profile_url).search(".contact-card")
    #contact_name =  extract_contact_name profile_page
    extract_address profile_page
  end

  def extract_contact_name page
    page.search(".contact-info .name").text.strip
  end

  def extract_address page
    Address.new(page.search(".contact-detail .dl-horizontal").text.split("\t\n").collect {|a| a.gsub(/\s+/," ").strip})
  end

  def seller_profile_url page
    page.search(".ellipsis a").attribute("href")
  end

  def extract_company_profile_url page
    page.search(".attrs .attr .cd").attribute("href")
  end

  def seller_name_from page
    page.search(".ellipsis a").text.strip
  end

  def extract_url_from page
    page.search(".title a").attribute("href")
  end

  def extract_attributes_from page
    page.search(".lwrap .attr").collect {|item| item.text.strip.gsub(/\s/," ") }
  end

  def extract_properties_from page
    page.search(".lwrap .prop").text.split(";").collect {|item| item.strip.gsub(/\s/," ") }
  end

  def extract_title_from page
    page.search(".title").text.strip
  end

  def page_url_for_number page_number
    @pagination_url.gsub("##number##", page_number.to_s)
  end

  def extract_maximum_page_count_from page
    page.search(".navi a")[-2].text.to_i
  end

end

CoffeeCrawler.new.crawl