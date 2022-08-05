# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in affiliation_id.gemspec
gemspec

gem 'rake', '~> 13.0'

group :test do
  gem 'rspec', '~> 3.0'
end

group :development, :test do
  gem 'guard-rspec', '~> 4.7', '>= 4.7.3', require: false
  gem 'overcommit', '~> 0.59.1', require: false
  gem 'rubocop', '~> 1.21'
end
