# frozen_string_literal: true
# Delete blacklight saved searches
every :day, at: '11:55pm' do
  rake "blacklight:delete_old_searches[1]"
end

# Remove files in /tmp owned by the deploy user that are older than 7 days
every :day, at: '1:00am' do
  command "/usr/bin/find /tmp -type f -mtime +7 -user deploy -execdir /bin/rm -- {} \\;"
end
