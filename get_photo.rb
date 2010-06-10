#!/usr/bin/ruby

require 'mechanize'
#require 'tmpfile'
#
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


agent = WWW::Mechanize.new

potd_page = agent.get(potd_url)

download_link = potd_page.link_with(:text => 'Download Wallpaper (1600 x 1200 pixels)')


tmpfile = Tempfile.new('potd_bg')

agent.get(download_link.href).save_as(tmpfile.path)

wp = Image.new(wp_height, wp_width) { self.background_color = bg_colour }

potd = ImageList.new(tmpfile.path)
potd.resize_to_fit!(wp_height*0.85, wp_width*0.85)

wp.composite!(potd, CenterGravity, OverCompositeOp)
wp.write(output_dir + "bg.jpg")

system("gconftool-2 --type string --set /desktop/gnome/background/picture_filename #{output_dir}/bg.jpg")

tmpfile.unlink
