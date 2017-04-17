My car can take up to 2 SD cards with digital music.

I don't want my entire iTunes collection - so - I created a playlist "Car" that contains the ones I do want.

These scripts take that m3u8 file and generate an output directory containing the files in the expected directory structure.

The shell script handles the iTunes odd line endings on the export file (and is called by the ruby script).

The ruby script parses the m3u8, removes duplicate files (iTunes match for some reason has duplicates), and does the directory creation/file copying.

### Normal use:

Export playlist from iTunes as Car.m3u8 to the same directory

    bundle exec ./car.rb target_directory_name
