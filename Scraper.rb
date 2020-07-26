require 'mechanize'
require 'pry'
require 'benchmark'

class Scraper
  attr_reader :url
  attr_accessor :abovegrade, :legaldesc, :primarybuilt, :deedref
  @@url = 'https://sdat.dat.maryland.gov/RealProperty/Pages/default.aspx'
  @@threads = []

  def scrape_address(number, name)
    @name = name
    @number = number
    @agent = Mechanize.new
    @@threads << Thread.new do
      start
    end
    @@threads.map(&:join)
  end

  def scrape_multi_address(array)
    array.each do |thing|
      number = thing.split(' ')[0]
      street = thing.split(' ')[1]
      scrape_address(number, street)
    end
  end

  def start
    # puts '....Loading URL'
    @page = @agent.get(@@url)
    # puts '....Grabbing page form'
    @form = @page.forms.first
    # puts '....Selecting dropdown values'
    @form.field_with(name: 'ctl00$ctl00$ctl00$MainContent$MainContent$cphMainContentArea$ucSearchType$wzrdRealPropertySearch$ucSearchType$ddlCounty').options[3].select
    @form.field_with(name: 'ctl00$ctl00$ctl00$MainContent$MainContent$cphMainContentArea$ucSearchType$wzrdRealPropertySearch$ucSearchType$ddlSearchType').options[1].select
    # puts '.... Success!'
    @page = @agent.submit(@form, @form.buttons.first)
    # puts 'Submitted!'
    pagetwo(@number, @name)
  end

  def pagetwo(number, name)
    # puts '.... Loading page 2'
    # puts '.... Grabbing page form'
    @form = @page.forms.first
    # puts ".... Filling text fields with #{number} #{name}"
    streetnumber = 'ctl00$ctl00$ctl00$MainContent$MainContent$cphMainContentArea$ucSearchType$wzrdRealPropertySearch$ucEnterData$txtStreenNumber'
    streetname = 'ctl00$ctl00$ctl00$MainContent$MainContent$cphMainContentArea$ucSearchType$wzrdRealPropertySearch$ucEnterData$txtStreetName'
    @form.field_with(name: streetnumber).value = number # '1621'
    @form.field_with(name: streetname).value = name # 'Darley'
    # puts '.... Submitting'
    @page = @agent.submit(@form, @form.buttons.last)
    savescrape
  end

  def savescrape
    @extracted = @page.search('table.ui-table', 'td')
    self.abovegrade = @extracted.search('span#MainContent_MainContent_cphMainContentArea_ucSearchType_wzrdRealPropertySearch_ucDetailsSearch_dlstDetaisSearch_Label19_0').text.strip
    self.legaldesc = @extracted.search('span#MainContent_MainContent_cphMainContentArea_ucSearchType_wzrdRealPropertySearch_ucDetailsSearch_dlstDetaisSearch_lblLegalDescription_0').text.strip
    self.primarybuilt = @page.search('span#MainContent_MainContent_cphMainContentArea_ucSearchType_wzrdRealPropertySearch_ucDetailsSearch_dlstDetaisSearch_Label18_0').text.strip
    self.deedref = @extracted.search('span#MainContent_MainContent_cphMainContentArea_ucSearchType_wzrdRealPropertySearch_ucDetailsSearch_dlstDetaisSearch_lblDedRef_0').text.strip
    values
  end

  def values
    puts abovegrade != '' ? "Above Grade Living Area: #{abovegrade}" : 'Above Grade Living Area: N/A'
    puts legaldesc != '' ? "Legal Description: #{legaldesc}" : 'Legal Description: N/A'
    puts primarybuilt != '' ? "Primary Structure Built: #{primarybuilt}" : 'Primary Structure Built: N/A'
    puts deedref != '' ? "Deed Reference: #{deedref}" : 'Deed Reference: N/A'
  end
end

list = ['1621 Darley', '1000 Darley', '1621 Darley', '1000 Darley', '1621 Darley', '1000 Darley', '1621 Darley', '1000 Darley', '1621 Darley', '1000 Darley', '1621 Darley', '1000 Darley', '1621 Darley', '1000 Darley']
Scraper.new.scrape_address(1621, 'Darley')
# Scraper.new.scrape_multi_address(list)

# puts Benchmark.measure {
#   15.times do
#     threads << Thread.new do
#       Scraper.new.scrape_address(1621, 'Darley')
#     end
#   end
#   threads.map(&:join)
# }
