# Adapted from https://github.com/robwierzbowski/jekyll-image-tag/blob/master/image_tag.rb
# Licensed under BSD 3-Clause New

require 'fileutils'

require "down"

module Jekyll
  class Image < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @markup = markup
      super
    end

    def render(context)
      render_markup = Liquid::Template.parse(@markup).render(context)

      # Gather settings
      site = context.registers[:site]
      settings = site.config['image'] ||= { 'presets' => nil}
      markup = /^(?:(?<preset>[^\s.:\/]+)\s+)?(src=")?(?<image_src>[^\s^"]+(\.[a-zA-Z0-9]{3,4})?)\s*(?<html_attr>[\s\S]+)?$/.match(render_markup)
      preset = settings['presets'][ markup[:preset] ] if markup[:preset]

      raise "Image Tag can't read this tag. Try {% image [preset or WxH] path/to/img.jpg [attr=\"value\"] %}." unless markup

      # Process instance
      instance = if preset
        {
          :width => preset['width'],
          :height => preset['height'],
          :src => markup[:image_src]
        }
      else
        { :src => markup[:image_src] }
      end

      # Process html attributes
      html_attr = if markup[:html_attr]
        Hash[ *markup[:html_attr].scan(/(?<attr>[^\s="]+)(?:="(?<value>[^"]+)")?\s?/).flatten ]
      else
        {}
      end

      if preset && preset['attr']
        html_attr = preset['attr'].merge(html_attr)
      end

      html_attr_string = html_attr.inject('') { |string, attrs|
        if attrs[1]
          string << "#{attrs[0]}=\"#{attrs[1]}\" "
        else
          string << "#{attrs[0]} "
        end
      }

      # Raise some exceptions before we start expensive processing
      raise "Image Tag can't find the \"#{markup[:preset]}\" preset. Check image: presets in _config.yml for a list of presets." unless preset || markup[:preset].nil?

      if ['http', 'https'].include?(URI.parse(instance[:src]).scheme)
        img_url = "https://weserv.supersandro.de/?url=#{instance[:src]}&w=#{html_attr['width']}&h=#{html_attr['height']}&output=webp&q=100"
        img_file = "#{File.basename(instance[:src], '.*').split('?')[0]}.webp"
        img_dir_rel = File.join('assets', 'img')
        img_dir = File.join(site.dest, img_dir_rel)
        img_path = File.join(img_dir, img_file)
  
        # Prevent Jekyll from erasing our generated files
        site.config['keep_files'] << img_dir_rel unless site.config['keep_files'].include?(img_dir_rel)
  
        FileUtils.mkdir_p(img_dir)
        Jekyll.logger.debug('Image:', "Downloading #{img_url}")
        file = Down.download(img_url)
        digest = Zlib::crc32(file.read)
        FileUtils.mv(file.path, img_path)
        FileUtils.chmod(0644, img_path)
        file.unlink
        Jekyll.logger.debug('Image:', "Moved image to #{img_path}")
  
        "<img src=\"\/#{File.join(img_dir_rel, img_file)}?#{digest}\" #{html_attr_string}>"
      else
        "<img src=\"\/#{instance[:src]}\" #{html_attr_string}>"
      end
    end
  end
end

Liquid::Template.register_tag('image', Jekyll::Image)
