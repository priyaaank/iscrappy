class Address

  attr_accessor :address

  def initialize(address)
    @address = address
  end

  def province
    extract_data /Province\/State/
  end

  def zip
    extract_data /Zip/
  end

  def fax
    extract_data /Fax/
  end

  def address
    extract_data /Address/
  end

  def country
    extract_data /Country\/Region/
  end

  def city
    extract_data /City/
  end

  def telephone
    extract_data /Telephone/
  end

  def mobile
    extract_data /Mobile Phone/
  end

  private

  def extract_data pattern
    matching_element = @address.find {|element| (element.split(":")[0]||"").match(pattern)}
    matching_element.nil? ? "N/A" : matching_element.split(":")[1].gsub(",","")
  end

end