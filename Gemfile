source "https://rubygems.org"

# Use a stable version of Jekyll that works well on macOS
gem "jekyll", "~> 4.2.0"

# Use the older sass converter to avoid protobuf issues
gem "jekyll-sass-converter", "~> 2.0"

# Basic plugins
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-sitemap"
  gem "jekyll-include-cache"
end

# Windows and JRuby compatibility
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Web server
gem "webrick", "~> 1.7"