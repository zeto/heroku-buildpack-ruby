require 'spec_helper'

describe "Upgrading ruby apps" do
  it "upgrades from 2.0.0 to 2.1.0" do
    app = Hatchet::Runner.new("default_ruby", stack: "heroku-16")
    app.setup!
    app.deploy do |app|
      # MALLOC_ARENA_MAX is persisted
      expect(app.run('echo "MALLOC_ARENA_MAX_is=$MALLOC_ARENA_MAX"')).to match("MALLOC_ARENA_MAX_is=2")

      `echo "" > Gemfile; echo "" > Gemfile.lock`
      puts `env BUNDLE_GEMFILE=./Gemfile bundle install`.inspect
      `echo "ruby '2.4.1'" > Gemfile`
      `git add -A; git commit -m update-ruby`
      app.push!
      expect(app.output).to match("2.4.1")
      expect(app.run("ruby -v")).to match("2.4.1")
      expect(app.output).to match("Ruby version change detected")

      # MALLOC_ARENA_MAX is persisted
      expect(app.run('echo "MALLOC_ARENA_MAX_is=$MALLOC_ARENA_MAX"')).to match("MALLOC_ARENA_MAX_is=2")
    end
  end
end
