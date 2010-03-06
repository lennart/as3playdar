
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  # version is a dot-delimited, 3 digit version string
  t.version       = '0.0.0'
  # Short summary of your library or project
  t.summary       = "API Implementation for Playdar"
  # Your name
  t.author        = 'Lucas Hrabovsky'
  # Your email or - better yet - the address of your project email list
  t.email         = 'hrabovsky.lucas@gmail.com'
  # The homepage of your library
  t.homepage      = ''
  t.libraries = [:"small-logger-src"]
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  filename: as3playdar-src.zip
  archive_type: zip
  url: http://github.com/lennart/as3playdar/zipball/0.0.0
  archive_path: lennart-as3playdar-cca81c9/src 
EOF
end

task :package => name
