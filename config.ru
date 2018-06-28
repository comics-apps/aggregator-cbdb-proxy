require "cdb-crawlr"
require "roda"

class App < Roda
  plugin :json, classes: [Array, Hash, CDB::Series, CDB::Issue]
  plugin :basic_auth

  route do |r|
    r.basic_auth { |user, pass| [user, pass] == [ENV["BASIC_USER"], ENV["BASIC_PASSWORD"]] }

    r.root do
      { status: "OK" }
    end

    r.on "publishers" do
      r.is :id do |id|
        r.get do
          CDB::Publisher.show(id, user_agent: ENV["USER_AGENT"])
        end
      end
    end

    r.on "series" do
      r.is do
        r.get do
          CDB::Series.search(r.params["query"], user_agent: ENV["USER_AGENT"])
        end
      end

      r.is :id do |id|
        r.get do
          series = CDB::Series.show(id, user_agent: ENV["USER_AGENT"])
          series.issues = series.issues.map{ |i| i.series = nil; i }
          series
        end
      end
    end

    r.on "issues" do
      r.is do
        r.get do
          CDB::Issue.search(r.params["query"], user_agent: ENV["USER_AGENT"])
        end
      end
    end
  end
end

run App.freeze.app
