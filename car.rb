#!/usr/bin/env ruby

require 'm3u8'
require 'yaml'
require 'fileutils'

# iTunes 12 on my iMac exports with what looks like CR only line endings that nothing else is willing to read.
# Shell out to a tr call to fix it - this takes Car.m3u8 and writes files.m3u8

system("./process.sh")

file = File.open 'files.m3u8'
playlist = M3u8::Playlist.read(file)

files = playlist.items.map(&:segment)

target = ARGV[0]

data = {}

# Parse m3u8 to data group/album/info

files.each do |path|
	parts = path.split('/')
	group = parts[-3]
	album = parts[-2]
	track = parts[-1]

	if !data.key?(group)
		data[group] = {}
	end

	if !data[group].key?(album)
		data[group][album] = {
			:path => File.dirname(path),
			:group => group,
			:album => album,
			:track => [track]
		}
	else
		data[group][album][:track] << track
	end
end

# iTunes match seems for some reason to contain duplicate tracks. These get a numeric counter. Run thru and reomve any such

data.each do |group, albums|
	albums.each do |album, info|
	
		tracks = []
		
		info[:track].each do |track|

			if track =~ /^(.*) \d\.(.{3})$/
				name = $1
				ext = $2

				if !info[:track].include?("#{name}.#{ext}")
					tracks << track
				end
			else
				tracks << track
			end
		end

		info[:track] = tracks
	end
end

# Remove any previous output

FileUtils.rm_rf(target)

# Copy files into target

data.each do |group, albums|
	puts group
	FileUtils.mkpath("#{target}/#{group}")

	albums.each do |album, tracks|
		puts "  #{album}"
		FileUtils.mkpath("#{target}/#{group}/#{album}")

		if File.exist?(tracks[:path])
			tracks[:track].each do |track|
				if File.file?("#{tracks[:path]}/#{track}")
					FileUtils.cp("#{tracks[:path]}/#{track}", "#{target}/#{group}/#{album}")
				else
					puts "Couldn't find track #{track} for #{tracks[:path]}"
				end
			end
		else
			puts "Not found #{tracks[:path]}"
		end
	end
end

