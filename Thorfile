class Gem < Thor
  desc "install VERSION", "install the gems"
  def install(version)
    %w[rspec-expectations rspec-mocks rspec-core rspec rspec-rails].each do |lib|
      system "gem install repos/#{lib}/pkg/#{lib}-#{version}.gem"
    end
  end
end
