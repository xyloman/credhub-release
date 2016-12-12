require 'erb'
require 'template'
require 'bosh/template/renderer'
require 'yaml'
require 'json'


def render(yaml)
  options = {:context => YAML.load(yaml).to_json}
  renderer = Bosh::Template::Renderer.new(options)
  renderer.render("../jobs/credhub/templates/encryption.conf.erb")
end

RSpec.describe "the encryption config template" do
  context "with hsm" do
    it "renders the Chrystoki config" do
      result = render(<<-EOF
        properties:
          credhub:
            encryption:
              provider: hsm
              hsm:
                host: "example.com"
                port: 1792
      EOF
)
      expect(result).to include "ServerName00 = example.com"
      expect(result).to include "ServerPort00 = 1792"
    end
  end

  context "with dsm" do
    it "renders the DSM client config" do
      result = render(<<-EOF
        properties:
          credhub:
            encryption:
              provider: dsm
              dsm:
                servers:
                  - host: 1.2.3.4
                    partition: fake-partition
                    ssh_private_key: fake-private-key
                  - host: 5.6.7.8
                    partition: fake-partition
                    ssh_private_key: fake-private-key
      EOF
)
      expect(result).to include "servers=1.2.3.4,5.6.7.8"
    end
  end

  context "with dev_internal" do
    it "should be empty" do
      result = render(<<-EOF
        properties:
          credhub:
            encryption:
              provider: dev_internal
      EOF
)
      expect(result.chomp).to be_empty
    end
  end
end