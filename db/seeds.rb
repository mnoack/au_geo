# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Required Debian/Ubuntu Package iso-codes
#/usr/share/xml/iso-codes/iso_3166.xml 
#/usr/share/xml/iso-codes/iso_3166_2.xml

require 'csv' # to parse localities data
require 'zip/zip'
require 'net/http' # to download iso codes if needed
require 'nokogiri' # to parse isocodes
require 'activerecord-import' # to bulk import all data

ISO_GIT_BASE     = "http://anonscm.debian.org/gitweb/?p=iso-codes/iso-codes.git;a=blob_plain;"
ISO_3166_URL     = ISO_GIT_BASE + "f=iso_3166/iso_3166.xml;hb=HEAD"
ISO_3166_2_URL   = ISO_GIT_BASE + "f=iso_3166_2/iso_3166_2.xml;hb=HEAD"
ABS_BASE         = "http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&"
ABS_POSTCODE_URL = ABS_BASE + "1270055003_poa_2011_aust_csv.zip&1270.0.55.003&Data%20Cubes&7A0CD4B1AD71C814CA2578D40012D4B2&0&July%202011&22.07.2011&Previous"
ABS_SUBURB_URL   = ABS_BASE + "1270055003_ssc_2011_aust_csv.zip&1270.0.55.003&Data%20Cubes&414A81A24C3049A8CA2578D40012D50C&0&July%202011&22.07.2011&Previous"

def load_countries
  path = get_iso_code('iso_3166.xml', ISO_3166_URL)
  doc = Nokogiri::XML(File.read(path))
  countries = doc.xpath('//iso_3166_entry').map do |element|
    [element[:alpha_2_code], element[:name]]
  end
  print "importing..."
  Country.import [:code, :name], countries
end

def load_subdivisions
  path = get_iso_code('iso_3166_2.xml', ISO_3166_2_URL)
  doc = Nokogiri::XML(File.read(path))
  subdivisions = doc.xpath('//iso_3166_2_entry').map do |element|
    [element[:code], element[:name], element[:code][0..1]]
  end
  print "importing..."
  Subdivision.import [:code, :name, :country_code], subdivisions
end

def load_au_localities(source = 'abs')
  au_states_by_code = Subdivision.where(:country_code => 'AU').index_by{|s| s.code.split('-').last}
  localities = []
  if source == 'abs'
    post_codes_by_maincode = {}
    path = get_abs_csv('POA_2011_AUST.csv', ABS_POSTCODE_URL)
    CSV.parse(File.read(path), :headers => :first_row).each do |row|
      existing = post_codes_by_maincode[row['SA1_MAINCODE_2011']]
      raise Exception, "POST CODE ALREADY TAKEN " if existing
      post_codes_by_maincode[row['SA1_MAINCODE_2011']] = row['POA_CODE_2011']
    end

    state_codes = {
      '1' => au_states_by_code['NSW'],
      '2' => au_states_by_code['VIC'],
      '3' => au_states_by_code['QLD'],
      '4' => au_states_by_code['SA'],
      '5' => au_states_by_code['WA'],
      '6' => au_states_by_code['TAS'],
      '7' => au_states_by_code['NT'],
      '8' => au_states_by_code['ACT']
    }
    suburbs_by_maincode = {}
    path = get_abs_csv('SSC_2011_AUST.csv', ABC_SUBURB_URL)
    CSV.parse(File.read(path), :headers => :first_row).each do |row|
      #suburb_name = row['SSC_NAME_2011'].gsub(/\ \((Tas\.|Vic\.|NSW|Qld|WA|SA|NT|ACT)\)$/, '')
      suburb_name = row['SSC_NAME_2011'].gsub(/\ \(.+\)$/, '')
      #puts suburb_name if suburb_name['(']
      state = state_codes[row['SSC_CODE_2011'][0]].try(:code)
      #puts "NO STATE: " + row.inspect if state.nil?
      post_code = post_codes_by_maincode[row['SA1_MAINCODE_2011']]
      #puts post_code if state.nil? || suburb_name['(']
      uniq = "#{suburb_name}#{state}#{post_code}"
      unless suburbs_by_maincode[uniq]
        suburbs_by_maincode[uniq] = [suburb_name, state, post_code]
        localities << [post_code, suburb_name, 9, state]
      end
    end
  else
    full_post_code_csv_as_string = File.read(ENV['AUS_POST_CSV'])
    CSV.parse(full_post_code_csv_as_string, :col_sep => ';', :headers => :first_row).each do |row|
      state = au_states_by_code[row['State']].code
      category = Locality::CATEGORY_STRING_TO_ID[row['Category'].strip]
      localities << [row['Pcode'], row['Locality'], category, state]
    end
  end
  print "importing..."
  Locality.import [:post_code, :name, :category_id, :subdivision_code], localities
end

def get_iso_code(filename, url)
  path = "/usr/share/xml/iso-codes/#{filename}"
  unless File.exists?(path)
    path = "#{Rails.root}/db/#{filename}"
    unless File.exists?(path)
      content = Net::HTTP.get(URI(url))
      File.open(path, 'w+', :encoding => 'ASCII-8BIT') {|f| f.write(content)}
    end
  end
  path
end

def get_abs_csv(filename, url)
  path = "#{Rails.root}/db/#{filename}"
  unless File.exists?(path)
    raise "Please download #{url}, unzip and store the csv at #{path} then re-run this task"
    #zip = Net::HTTP.get(URI(url))
    #File.open(path+'.zip', 'w+', :encoding => 'BINARY') {|f| f.write(zip)}
    #content = Zip::ZipFile.open(path+".zip", :encoding => 'BINARY') do |zipfile|
    #  zipfile.read(filename)
    #end
    #File.open(path, 'w+', :encoding => 'ASCII-8BIT') {|f| f.write(content)}
  end
  path
end

def load_helper(klass)
  print "#{klass} import"
  klass.delete_all
  yield
  puts "Loaded #{klass.count} entries"
end

load_helper(Country)     { load_countries }
load_helper(Subdivision) { load_subdivisions }
load_helper(Locality)    { load_au_localities }
