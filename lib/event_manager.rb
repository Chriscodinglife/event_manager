require 'csv'
require 'erb'
require 'google/apis/civicinfo_v2'


def cleans_zip_code(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end


def cleans_phone_number(number)

    number = number.gsub(/[^\d]/, "")

    if number.start_with?("1") && number.length >= 11
        number[1..10]
    elsif number.length == 10
        number
    else
        return "Bad Number"
    end

end


def gets_hour(hours, date)

    hour = Time.strptime(date, '%m/%d/%y %H:%M').hour

    if not hours.has_key?(hour)
        hours[hour] = 1
    end

    hours[hour] += 1

end


def gets_days(days, date)

    day = Time.strptime(date, '%m/%d/%y %H:%M').wday

    if not days.has_key?(day)
        days[day] = 1
    end

    days[day] += 1

end


def outputs_hours(hours)

    hours.each_pair do |key, value|
        puts "At Hour #{key} there were #{value} registrations"
    end

end


def outputs_days(days)

    days.each_pair do |key, value|
        puts "On Day #{key} there were #{value} registrations"
    end

end


def legislators_by_zipcode(zipcode)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = File.read('secret.key').strip

    begin
        legislators = civic_info.representative_info_by_address(
            address: zipcode,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end

end


def save_thank_you_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
        file.puts form_letter
    end

end


puts 'Event Manager Initialized!'

csv_file = 'event_attendees.csv'

contents = CSV.open(
    csv_file,
    headers: true,
    header_converters: :symbol
)

template_file = 'form_letter.erb'
template_letter = File.read(template_file)
erb_template = ERB.new(template_letter)

hours = {}
days = {}

contents.each do |row|
    # id = row[0]
    # name = row[:first_name]

    # zipcode = cleans_zip_code(row[:zipcode])

    # legislators = legislators_by_zipcode(zipcode)

    # form_letter = erb_template.result(binding)

    # save_thank_you_letter(id, form_letter)

    # number = cleans_phone_number(row[:homephone])

    # puts number

    gets_hour(hours, row[:regdate])

    gets_days(days, row[:regdate])

end

outputs_hours(hours)
outputs_days(days)
