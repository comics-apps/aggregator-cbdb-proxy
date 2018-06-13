require "cdb-crawlr"
require "roda"

class App < Roda
  plugin :json
  plugin :basic_auth

  route do |r|
    r.basic_auth { |user, pass| [user, pass] == [ENV["BASIC_USER"], ENV["BASIC_PASSWORD"]] }

    r.root do
      { status: "OK" }
    end

    r.on "series" do
      r.is do
        r.get do
          CDB::Series.search(r.params["query"], user_agent: ENV["USER_AGENT"])
        end
      end

      r.is ":id" do
        r.get do
          CDB::Series.show(r.params[:id], user_agent: ENV["USER_AGENT"])
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
