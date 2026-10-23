source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.4"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use PostgreSQL as the database for Active Record
gem "pg", "~> 1.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Contraseñas (has_secure_password)
gem "bcrypt", "~> 3.1.7"
# Aislamiento de datos por empresa
gem "acts_as_tenant", "~> 1.0"
# Verificación en dos pasos (TOTP) y código QR para la app autenticadora
gem "rotp", "~> 6.3"
gem "rqrcode", "~> 2.2"
# Importación de colaboradores desde Excel / CSV
gem "roo", "~> 2.10"
gem "csv"
# Traducciones al español de mensajes de error, fechas y números
gem "rails-i18n", "~> 8.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # Ver los correos enviados en /letter_opener
  gem "letter_opener_web", "~> 3.0"
end
