#encoding: utf-8

$fails=0

gem 'nokogiri'
require 'nokogiri'
require 'open-uri'

$currentPage = '';

def dprint(string)
    printf "#{$currentPage}	#{string}"
end

def dsuccess
    printf "	SUCCESS\n"
end

def dfail
    printf "	FAIL\n"
    $fails+=1
end

#methods
def do_checkInnerHtmlNonEmpty(xpath, html)
    dprint "checkInnerHtmlNonEmpty	#{xpath}"
    if html.at_xpath(xpath).text.empty?
	dfail
    else
	dsuccess
    end
end

def do_checkcount(xpath, count, html)
    dprint "CHECKCOUNT:	#{xpath}	#{count.to_s}"
    if html.xpath(xpath).count == count
	dsuccess
    else
	dfail
    end
end

def do_checkgt(xpath, count, html)
    dprint "CHECKGT:	#{xpath}	#{count.to_s}"
    if html.xpath(xpath).count > count
	dsuccess
    else
	dfail "	(#{html.xpath(xpath).count.to_s})\n"
    end
end

def do_checkattributeNonEmpty(attr, html)
    dprint "CHECKattributeNonEmpty:	#{attr}	#{html.path}"
    if html[attr].to_s.empty?
	dfail
    else
	dsuccess
    end
end

def do_call(name, html)
    $procedures.each {|procedure|
	if procedure["name"] == name
	    dprint "CALL:	#{name}"
	    dsuccess
	    list = []
	    procedure.children.each {|one|
		list.push(one) if one.parent == procedure
	    }
	    execute(list, html)
	    return
	end
    }
    puts "CALL:	#{name}	FAIL	UNKNOWN PROCEDURE" if !ARGV.include?('--production')
end

def do_foreach(command, xpath, html)
    dprint "FORAECH:	#{xpath}	SUCCESS"
    dsuccess
    list = []
    command.children.each {|one|
	list.push(one) if one.parent == command
    }

    html.xpath(xpath).each {|one|
#	puts one.path
        execute(list, Nokogiri::HTML(one.to_s))
    }
end

def do_foreachForAttr(command, xpath, html)
    puts "FORAECHforAttr:	#{xpath}	SUCCESS"
    list = []
    command.children.each {|one|
	list.push(one) if one.parent == command
    }

    html.xpath(xpath).each {|one|
        execute(list, one)
    }
end


#execution
def execute(callList, html)
    callList.each {|command|
	next if command.name == 'text'
	next if command.name == 'comment'
	automation command, html
    }
end

#automation
def automation(command, html)
    case command.name
	when "checkgt"
	    do_checkgt command["xpath"], command.text.to_i, html
	when "checkcount"
	    do_checkcount command["xpath"], command.text.to_i, html
	when "checkattributeNonEmpty"
	    do_checkattributeNonEmpty command["attr"], html
	when "call"
	    do_call command["name"], html
	when "foreach"
	    do_foreach command, command["xpath"], html
	when "foreachForAttr"
	    do_foreachForAttr command, command["xpath"], html
	when "checkInnerHtmlNonEmpty"
	    do_checkInnerHtmlNonEmpty command["xpath"], html
	else
	    puts "UNKNOWN COMMAND:	#{command.name}" if !ARGV.include?('--run')
    end
end

#main
def main(file, urlbase)
    script = Nokogiri::XML(File.read(file))

    $procedures = script.xpath("//root/procedures/procedure")
    $urls = script.xpath("//root/pages/url")
    $urlsLists = script.xpath("//root/pages/urls")

    $urls.each { |url|
        uri = url["url"]
        url = Nokogiri::XML(url.to_s)
        #download this url into `htmlraw` variable
        $currentPage = urlbase + uri
        htmlraw = open($currentPage).read
        html = Nokogiri::HTML(htmlraw)
        list = []
        checks = url.at_xpath('//checks')
        checks.children.each {|one|
	list.push(one) if one.parent == checks
        }
    
        execute list, html
    }

    $urlsLists.each { |rlist|
        rlist = Nokogiri::XML(rlist.to_s)
        list = []
        checks = rlist.at_xpath('//checks')
        checks.children.each {|one|
	    list.push(one) if one.parent == checks
        }

        rlist.xpath('//url').each { |url|
	    uri = url.text
            #download this url into `htmlraw` variable
	    $currentPage = urlbase + uri
            htmlraw = open($currentPage).read
            html = Nokogiri::HTML(htmlraw)
            execute list, html
        }
    }

    if $fails > 0
        puts "We have a fails"
	raise $fails
    end
end
