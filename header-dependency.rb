#!/usr/bin/env ruby

root_file        = ARGV[0]
all_proj_headers = ARGV[1]

proj_header_map = { }
all_included_headers = { }

File.open(all_proj_headers, "r").each do |line|
    line.chomp!
    basename = File.basename(line)
    proj_header_map[basename] = line
end

def included_headers targetfile, m, m1, chain
    chain << File.basename(targetfile)
    File.open(targetfile, "r").each do |l|
        l.chomp!
        #puts "reading line: #{l}"
        matchdata = /^\s*#\s*include\s+(<|\")([^>\"]+)(>|\").*$/.match(l)
        next if matchdata.nil?
        #puts "#{matchdata.inspect}"
        h = matchdata.captures[1].strip
        if m.has_key? h
            m[h] += 1
        else
            if m1.has_key? h
                m[h] = 1
                included_headers(m1[h], m, m1, chain)
            end
        end
    end
    puts "#{chain.join(' => ')}"
    chain.pop
end

included_headers(root_file, all_included_headers, proj_header_map, [])

#all_included_headers.each do |k,v|
#    puts "#{k} => #{v}"
#end

