clearing :on

guard :minitest do
  # Run that test file if modfied:
  watch(%r{^test/(.*)\/?(.*)_test\.rb$})

  # Run corresponding test file if lib/ file modified:
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}#{m[2]}_test.rb" }

  # Run test suite if following are modified:
  watch(%r{^test/test_helper\.rb$})      { 'test' }
  watch(%r{^rooms\.rb$})                 { 'test' }
end
