desc "Outputs list of shops that have installed the app"
task :shops => :environment do
  url_column = Shop.column_names.detect{|c| c =~ /url|domain/}
  puts Shop.select("id,#{url_column},token").all.to_json
end