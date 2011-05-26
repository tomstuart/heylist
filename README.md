## Hey List

    $ git clone git@github.com:freerange/heylist.git
    $ cd heylist
    $ bundle install
    $ cp config.example.yml config.yml
    # fill in config.yml with credentials from the shared keychain

### Crontab

    7 */4 * * * cd /home/freerange/heylist/ && /usr/local/bin/bundle exec /usr/bin/ruby scrape.rb >> /home/freerange/heylist/output.log 2>&1