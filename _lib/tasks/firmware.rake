require "selenium-webdriver"
require 'graphql'

RELEASES_URL = 'https://community.ui.com/RELEASES'
GRAPHQL_ENDPOINT = 'https://community.svc.ui.com/'

FirmwarePage = Struct.new(:title, :url)

ReleasesSchema = GraphQL::Schema.from_definition(File.join(File.dirname(__FILE__), '../ui_community.graphql'))

ALL_TAGS =  %w[unifi-routing-switching unifi-wireless unifi-cloud-gateway unifi-switching wifiman unifi-design-center unifi-protect unifi-access unifi-talk unifi-connect site-manager uid unifi-mobility unifi-drive innerspace uisp-app uisp-mobile aircontrol isp-design-center airmax airmax-aircube airfiber-ltu 60GHz wave edgemax ufiber unms solar uisp-power amplifi general new-to-unifi unifi-play]


desc 'Reload releases from GraphQL'
task :firmware do

end

desc 'Reload firmware files from UI'
task :firmware_webdriver do
  results = []

  # define the browser options
  options = Selenium::WebDriver::Chrome::Options.new

  #options.add_argument("user-data-dir=#{ENV['HOME']}/Library/Application Support/Google/Chrome/")
  # create a driver instance to control Chrome
  # with the specified options
  driver = Selenium::WebDriver.for :chrome, options: options

  driver.navigate.to(RELEASES_URL)

  # wait for products to be loaded and rendered
  sleep(10)

  10.times do |i|
    LIMIT = 30
    offset = i * LIMIT

    options = {
      operationName:"GetReleases",
      variables:
        {
          limit: LIMIT,
          offset:offset,
          statuses:"PUBLISHED",
          tags: ALL_TAGS,
          betas:[],
          alphas: [],
          userIsFollowing:false,
          sortBy:"LATEST",
          filterTags:null,
          filterEATags:null
        },
      query: null
    }

    driver.post('https://community.svc.ui.com/', )
  end

  driver.quit

  open(File.join( File.dirname(__FILE__), '../../tmp/firmwares.yaml'),  'w') do |f|
    f.write results.to_yaml
  end
end