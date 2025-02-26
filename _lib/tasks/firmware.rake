require "selenium-webdriver"
require "graphql/client"
require "graphql/client/http"
require 'net/http'
require 'open-uri'
require 'uri'

RELEASES_URL = 'https://community.ui.com/RELEASES'
GRAPHQL_ENDPOINT = 'https://community.svc.ui.com/graphql'
MAX_LIMIT_SIZE = 100

FirmwarePage = Struct.new(:id, :title, :slug, :version, :stage, :links, :type, :tags, :group_id, :content)

# Star Wars API example wrapper
module UbiquityGraphAPI
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new(GRAPHQL_ENDPOINT)

  # Fetch latest schema on init, this will make a network request
  Schema = GraphQL::Schema.from_definition('_lib/releases.graphql')

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

end

ALL_TAGS = %w[unifi-routing-switching unifi-wireless unifi-cloud-gateway unifi-switching wifiman unifi-design-center unifi-protect unifi-access unifi-talk unifi-connect site-manager uid unifi-mobility unifi-drive innerspace uisp-app uisp-mobile aircontrol isp-design-center airmax airmax-aircube airfiber-ltu 60GHz wave edgemax ufiber unms solar uisp-power amplifi general new-to-unifi unifi-play]

desc 'Reload releases from GraphQL'
task :firmware do

  RELEASES_QUERY = UbiquityGraphAPI::Client.parse <<~GRAPHQL
    query (
      $limit: Int
      $offset: Int
      $searchTerm: String
      $sortBy: ReleasesSortBy
      $sortDirection: ReleasesSortDirection
      $stage: ReleaseStage
      $statuses: [ReleaseStatus!]
      $tagMatchType: TagMatchType
      $tags: [String!]
      $betas: [String!]
      $alphas: [String!]
      $filterTags: [String!]
      $filterEATags: [String!]
      $filterAlphaTags: [String!]
      $type: ReleaseType
      $featuredOnly: Boolean
      $nonFeaturedOnly: Boolean
      $userIsFollowing: Boolean
    ) {
      releases(
        limit: $limit
        offset: $offset
        searchTerm: $searchTerm
        sortBy: $sortBy
        sortDirection: $sortDirection
        stage: $stage
        statuses: $statuses
        tagMatchType: $tagMatchType
        tags: $tags
        betas: $betas
        alphas: $alphas
        filterTags: $filterTags
        filterEATags: $filterEATags
        filterAlphaTags: $filterAlphaTags
        type: $type
        featuredOnly: $featuredOnly
        nonFeaturedOnly: $nonFeaturedOnly
        userIsFollowing: $userIsFollowing
      ) {
        items {
          id
          slug
          type
          title
          version
          groupId
          links {
            url
          }   
          content {
            type
            ... on AttachmentsContent {
              files {
                url
              } 
            }     
          }   
          stage
          tags
          betas
          alphas
          isFeatured
          isLocked
          hasUiEngagement
          createdAt
          lastActivityAt
          updatedAt      
          __typename
        }
        pageInfo {
          limit
          offset
          __typename
        }
        totalCount
        __typename
      }
    }

  GRAPHQL

  results = []

  length_measure = UbiquityGraphAPI::Client.query(RELEASES_QUERY, variables: {
    limit: MAX_LIMIT_SIZE,
  })
  PAGES = length_measure.data.to_h['releases']['totalCount'] % MAX_LIMIT_SIZE
  PAGES.times do |i|
    page = UbiquityGraphAPI::Client.query(RELEASES_QUERY, variables: {
      limit: MAX_LIMIT_SIZE,
      offset: i * MAX_LIMIT_SIZE,
    })
    page.data.to_h['releases']['items'].each do |release|
      result = FirmwarePage.new(release['id'], release['title'], release['slug'], release['version'], release['stage'], release['links'], release['type'], release['tags'], release['groupId'], release['content'])
      results << result
    end
  end

  open(File.join(File.dirname(__FILE__), '../../_data/firmwares.yaml'), 'w') do |f|
    f.write results.to_yaml
  end

  urls = results.flat_map { |r| r['links'].map { |l| l['url'] } }.uniq
  open(File.join(File.dirname(__FILE__), '../../_data/urls.yaml'), 'w') do |f|
    f.write urls.to_yaml
  end
end

desc 'Reload firmware files from UI'
task :firmware_webdriver do
  results = []

  # define the browser options
  options = Selenium::WebDriver::Chrome::Options.new

  # options.add_argument("user-data-dir=#{ENV['HOME']}/Library/Application Support/Google/Chrome/")
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
      operationName: "GetReleases",
      variables:
        {
          limit: LIMIT,
          offset: offset,
          statuses: "PUBLISHED",
          tags: ALL_TAGS,
          betas: [],
          alphas: [],
          userIsFollowing: false,
          sortBy: "LATEST",
          filterTags: null,
          filterEATags: null
        },
      query: null
    }

    driver.post('https://community.svc.ui.com/',)
  end

  driver.quit

  open(File.join(File.dirname(__FILE__), '../../tmp/firmwares.yaml'), 'w') do |f|
    f.write results.to_yaml
  end
end

desc 'Download all URLs'
task :download_urls do
  FILE_PATH = File.join(File.dirname(__FILE__), '../../_data/firmwares.yaml')
  URLS = YAML.load_file(
    FILE_PATH,
    permitted_classes: [FirmwarePage, Symbol],
  )

  IGNORE_URLS = %w[https://download.uid.ui.com/?app=DESKTOP-IDENTITY-STANDARD-MACOS https://download.uid.ui.com/?app=DESKTOP-IDENTITY-STANDARD-WINDOWS https://download.uid.ui.com/?app=DESKTOP-IDENTITY-STANDARD-WINDOWS-MSI]
  URLS.each do |fw|
    fw['links'].each do |l|
      url = l['url']
      filename = File.basename(URI.parse(url).path)
      puts  "Downloading #{filename}"
      output_file = File.join('tmp/downloads', filename)
      next if url.include? 'https://apps.apple.com/'
      next if url.include? 'https://play.google.com/'
      next if IGNORE_URLS.include? url
      URI.open(url) do |f|
        File.write(output_file, f.read)
      end
    rescue => e
      puts("Unable to download #{url} because: \n\n#{e.inspect}")
      next
    end
  end
end