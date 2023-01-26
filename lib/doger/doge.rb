# frozen_string_literal: true

require 'core_ext/range'
require 'doger/color'
require 'doger/geometry'
require 'doger/text_region'
require 'doger/zone'
require 'mini_magick'

module Doger
  class Doge
    # @return [Array<Doger::Zone>]
    attr_writer :zones

    # @return [Doger::Doge]
    def initialize(image_path, options = {})
      @image = MiniMagick::Image.new(image_path)
      @image_diagonal_size =
        Doger::Geometry::Point.new(0, 0).distance_to(Doger::Geometry::Point.new(@image.width, @image.height))
      @colors = options[:colors] || Doger.config.default_colors
      @pointsizes = options[:pointsizes] || Doger.config.default_pointsizes
      if options[:auto_generate_zones]
        horizontal_divisions = options[:horizontal_divisions] || Doger.config.default_horizontal_divisions
        vertical_divisions = options[:vertical_divisions] || Doger.config.default_vertical_divisions
        generate_zones(horizontal_divisions: horizontal_divisions,
                       vertical_divisions: vertical_divisions)
      else
        @zones = options[:zones]
      end
    end

    def find_zone(id)
      zones.find { |zone| zone.object_id == id }
    end

    def generate_image(destination_path, phrases)
      @last_used_zone = nil
      @occupied_text_regions = []
      @used_colors = []
      @convert = MiniMagick::Tool::Convert.new
      @convert << @image.path
      @convert.strip
      @convert.quality(format('%d%%', Doger.config.image_quality))
      @convert.font('Comic-Sans-MS')
      @convert.gravity('Center')
      phrases.each { |phrase| add_convert_options_for_text(phrase) }
      @convert << destination_path
      @convert.call
    end

    def zones
      @zones ||= generate_zones
    end

    private

    # adds the imagemagick convert command options for writing text in a random spot, color, and pointsize
    def add_convert_options_for_text(text)
      zone = random_unused_zone
      text_options = random_options_for_text_in_zone(text, zone)
      @convert.fill(text_options[:color])
      @convert.pointsize(text_options[:pointsize])
      @convert << '-annotate' << "#{text_options[:x_shift]}#{text_options[:y_shift]}" << text
    end

    def adjustment_for_fitting_dimension_to_view(text_min, text_max, image_min, image_max)
      if text_min < image_min
        image_min - text_min
      elsif text_max > image_max
        image_max - text_max
      else
        0
      end
    end

    def generate_zones(horizontal_divisions: Doger.config.default_horizontal_divisions,
                       vertical_divisions: Doger.config.default_vertical_divisions)
      x_zone_len = (@image.width / horizontal_divisions).ceil
      y_zone_len = (@image.height / vertical_divisions).ceil
      zones = []
      0.upto(horizontal_divisions - 1) do |x|
        0.upto(vertical_divisions - 1) do |y|
          top_left = Doger::Geometry::Point.new(x * x_zone_len, y * y_zone_len)
          bottom_right = Doger::Geometry::Point.new((x + 1) * x_zone_len, (y + 1) * y_zone_len)
          zones << Doger::Zone.new(top_left, bottom_right)
        end
      end
      @zones = zones
    end

    # given a text, zone, picks a spot in the zone and a pointsize, then calculates the
    # space the text would take up, shifting it back into view if the text goes out of bounds (image
    # boundaries with padding) and then makes sure it is not occupying space used by other text,
    # otherwise it starts over with a new random spot and pointsize.
    # returns x_shift, y_shift, pointsize values for imagemagick's -annotate feature with -gravity Center
    def random_options_for_text_in_zone(text, zone)
      padding = rand(@pointsizes.min..(@pointsizes.min * 3))
      text_options = {}
      loop do
        text_options[:random_point] = zone.random_point
        text_options[:pointsize] = @pointsizes.sample
        text_options[:color] = random_unused_color(text_options[:random_point])
        # determine height and width of text
        text_height = (text_options[:pointsize] * 1.25).ceil
        text_width  = (text.length * (text_options[:pointsize] / 2.0)).ceil
        # determine top left and bottom right corner coordinates
        top_left_x = text_options[:random_point].x - (text_width / 2)
        top_left_y = text_options[:random_point].y - (text_height / 2)
        bottom_right_x = text_options[:random_point].x + (text_width / 2)
        bottom_right_y = text_options[:random_point].y + (text_height / 2)
        # determine adjustment needed for shifting text back into view if any sides are out of bounds
        text_options[:x_adjustment] =
          adjustment_for_fitting_dimension_to_view(top_left_x, bottom_right_x, padding, @image.width - padding)
        text_options[:y_adjustment] =
          adjustment_for_fitting_dimension_to_view(top_left_y, bottom_right_y, padding, @image.height - padding)
        text_options[:text_region] = Doger::TextRegion.new(
          Geometry::Point.new(
            top_left_x + text_options[:x_adjustment],
            top_left_y + text_options[:y_adjustment]
          ),
          Geometry::Point.new(
            bottom_right_x + text_options[:x_adjustment],
            bottom_right_y + text_options[:y_adjustment]
          ),
          text_options[:color]
        )
        # loop until empty space found
        break unless space_already_occupied?(text_options[:text_region])
      end
      @occupied_text_regions << text_options[:text_region]
      x = text_options[:random_point].x + text_options[:x_adjustment]
      y = text_options[:random_point].y + text_options[:y_adjustment]
      # convert absolute coordinates to Center gravity shift values
      x_shift = x - (@image.width / 2)
      y_shift = y - (@image.height / 2)
      text_options[:x_shift] = format('%+d', x_shift)
      text_options[:y_shift] = format('%+d', y_shift)
      text_options
    end

    def random_unused_color(point)
      nearby_text_regions =
        @occupied_text_regions.find_all do |occupied_text_region|
          point.distance_to(occupied_text_region.center) <= (@image_diagonal_size / 2.5)
        end
      nearby_colors = nearby_text_regions.map(&:color)
      # don't check for @used_colors after all colors have been used
      unavailable_colors = @used_colors.size >= @colors.size ? nearby_colors : @used_colors & nearby_colors
      available_colors = @colors - unavailable_colors
      available_colors = @colors if available_colors.empty?
      color = available_colors.sample
      @used_colors << color
      color
    end

    # picks a random unused zone from all available zones the first time, each subsequent
    # time, it makes a weighted array based on the distance from last used zone to available zones
    #
    # @return [Doger::Zone]
    def random_unused_zone
      @available_zone_ids ||= zones.map(&:object_id)
      @available_zone_ids += zones.map(&:object_id) if @available_zone_ids.empty?
      weighted_zone_id_array =
        if @last_used_zone
          last_zone_center = @last_used_zone.center
          weights = zones.map { |zone| [zone.object_id, last_zone_center.distance_to(zone.center).ceil] }.to_h
          array = []
          (@available_zone_ids - [@last_used_zone.object_id]).each do |zone_id|
            weights[zone_id].times { array << zone_id }
          end
          array
        else
          @available_zone_ids
        end
      random_zone_id = weighted_zone_id_array.sample
      @available_zone_ids.delete(random_zone_id)
      @last_used_zone = find_zone(random_zone_id)
    end

    # iterates over list of occupied text regions and returns true if text_region overlaps with any one of them,
    # returns false if there is no overlap
    #
    # @return [Boolean]
    def space_already_occupied?(text_region)
      @occupied_text_regions.each do |occupied_text_region|
        return true if text_region.overlaps?(occupied_text_region)
      end
      false
    end
  end
end
