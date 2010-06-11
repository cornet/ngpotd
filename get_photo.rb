#!/usr/bin/ruby

require 'mechanize'

# https://bugs.launchpad.net/ubuntu/+source/librmagick-ruby/+bug/565461
RMAGICK_BYPASS_VERSION_TEST = true
require 'RMagick'
include Magick

#################################################
# Configuration
#################################################
potd_url = "http://photography.nationalgeographic.com/photography/photo-of-the-day/"

wp_height    = 1024
wp_width     = 768
bg_colour    = "black"

output_dir = "/home/nathan/Pictures/ng_potd/"


#################################################
# Main Script
#################################################
agent = WWW::Mechanize.new

potd_page = agent.get(potd_url)

wp_link = potd_page.link_with(:text => 'Download Wallpaper (1600 x 1200 pixels)')

# Looks like there isn't a high res every day, use low res instead
if wp_link
  wp_url = wp_link.href
else
  wp_url = potd_page.search('div.primary_photo a img')[0].attributes['src']
end

tmpfile = Tempfile.new('potd_bg')

agent.get(wp_url).save_as(tmpfile.path)

wp = Image.new(wp_height, wp_width) { self.background_color = bg_colour }

potd = ImageList.new(tmpfile.path)
potd.resize_to_fit!(wp_height*0.85, wp_width*0.85)

wp.composite!(potd, CenterGravity, OverCompositeOp)
wp.write(output_dir + "bg.jpg")

system("gconftool-2 --type string --set /desktop/gnome/background/picture_filename #{output_dir}/bg.jpg")

tmpfile.unlink
