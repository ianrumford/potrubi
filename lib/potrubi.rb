
# Potrubi

gemName = 'potrubi'

requireList = %w(bootstrap)
requireList.each {|r| require_relative "#{gemName}/#{r}"}

__END__
