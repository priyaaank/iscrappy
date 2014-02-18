class CoffeeSeller

  attr_accessor :seller_name, :product_name, :attributes, :properties, :product_detail_url, :seller_contact_url, :website, :company_profile_url, :address

  def initialize(seller_name, product_name, attributes, properties, product_detail_url, seller_contact_url, company_profile_url, website, address)
    @seller_name = seller_name.gsub(',',' ')
    @product_name = product_name.gsub(',',' ')
    @attributes = attributes
    @properties = properties
    @product_detail_url = product_detail_url
    @seller_contact_url = seller_contact_url
    @website = website
    @company_profile_url = company_profile_url
    @address = address
  end

  def to_csv_record
    "#{@product_name},#{@product_detail_url},#{price_range},,,,,,,#{minimum_order_quantity},,#{supply_capacity},#{@seller_name},#{@seller_contact_url},#{@company_profile_url},#{@address.telephone},#{@address.mobile},#{@address.address},#{@address.zip},#{@address.country},#{@address.province},#{@address.city},#{@website}"
  end

  def minimum_order_quantity
    @attributes.find { |element| element.match(/Min. Order/) } || "Not available"
  end

  def price_range
    @attributes.find { |element| element.match(/FOB Price/) } || "Not available"
  end

  def supply_capacity
    "Not available"
  end

  def quantity_ability
    "Not available"
  end

end