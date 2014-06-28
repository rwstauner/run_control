if !ENV['NO_VAGRANT_RC']

  # Check env and pwd for additional customizations.
  [
    (ENV['VAGRANT_CONFIG'] || "#{ENV['HOME']}/run_control/vagrant/config.rb"),
    ENV['EXTRA_VAGRANT_CONFIG'],
    "Vagrantfile.local",
  ].each do |config|
    if (not "#{config}".empty?) and File.exists?(config)
      load(config)
    end
  end

end
