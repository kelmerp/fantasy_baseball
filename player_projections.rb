require 'rest_client'
require 'json'
require 'pry'
require 'csv'

class PlayerProjections

  POSITIONS = %w{1B 2B SS C 3B OF DH}

  def initialize(csv)
    response_batters = RestClient.get 'http://www.kimonolabs.com/api/bt868shs?apikey=455e95d967d14e53ad7188d10746bcf6'
    json_batters = JSON.parse(response_batters)
    @batters = json_batters['results']['collection1']
    @csv = csv
  end

  def to_csv
    batters = parse_batters
    CSV.open(@csv, 'wb') do |csv|
      csv << batters.first.keys
      batters.each do |hash|
        csv << hash.values
      end
    end
  end

  private

  def parse_batters
    batters = []
    @batters.each do |batter|
      player_info = batter['name']['text']
      positions = []

      find_positions(positions, player_info)

      batters << { name: find_name(player_info), position: positions.join(', '),
                  at_bats: batter['ab'].to_i, runs: batter['runs'].to_i,
                  home_runs: batter['hr'].to_i, rbi: batter['rbi'].to_i,
                  stolen_bases: batter['sb'].to_i, walks: batter['bb'].to_i,
                  strike_outs: batter['k'].to_i,
                  total_bases_non_hr: total_bases_non_hr(batter['slg'].to_f, batter['ab'].to_i, batter['hr'].to_i),
                  total_points: hitter_total_points(batter['ab'].to_i, batter['runs'].to_i, total_bases_non_hr(batter['slg'].to_f, batter['ab'].to_i, batter['hr'].to_i), batter['hr'].to_i, batter['rbi'].to_i, batter['sb'].to_i, batter['bb'].to_i, batter['k'].to_i) }
    end
    batters
  end

  def find_positions(arr, player)
    POSITIONS.map { |position|
      arr << position if player.gsub(',','').split(' ').include?(position)
    }
  end

  def find_name(player)
    x = player.split('.')
    x.shift
    x.join('').split(',')[0][1..-1]
  end

  def total_bases_non_hr(slg, ab, hr)
    (slg * ab) - (hr * 4)
  end

  def hitter_total_points(ab, r, tb, hr, rbi, sb, bb, k)
    (-0.5 * ab) + (1 * r) + (1.2533 * tb) + (4.5 * hr) + (1 * rbi) + (2 * sb) + (1 * bb) + (-0.7 + k)
  end
end

x = PlayerProjections.new(ARGV[0])
x.to_csv
