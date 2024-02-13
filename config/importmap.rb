# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
# Newly added - Matt Hosier
pin "bootstrap", to: "bootstrap/dist/css/bootstrap.min.css"
pin "bootstrap.bundle", to: "bootstrap/dist/js/bootstrap.bundle.min.js"
# end here
pin_all_from "app/javascript/controllers", under: "controllers"
