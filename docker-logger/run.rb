#!/usr/bin/env ruby

sleep_sec_dur = ARGV.length >= 1 ? ARGV[0].to_i : 1

# flush both the stdout and stderr immediately
$stdout.sync = true
$stderr.sync = true

1.step do |index|
    $stdout.puts "This is stdout message ##{index}"
    sleep sleep_sec_dur
    $stderr.puts "This is stderr message ##{index}"
    sleep sleep_sec_dur
end
