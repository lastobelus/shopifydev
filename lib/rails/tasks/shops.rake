desc "Outputs list of shops that have installed the app"
task :shops => :environment do
  url_column = 'myshopify_domain'
  url_column = 'domain' unless Shop.column_names.include?(url_column)
  url_column = 'url' unless Shop.column_names.include?(url_column)
  json = {
    shops: Shop.select("id,#{url_column},token").all.map(&:attributes),
    url_column: url_column
  }.to_json
  puts "----snip----"
  puts json
end