require 'abbrev'


BOOKS = [
    "Genesis",
    "Exodus",
    "Leviticus",
    "Numbers",
    "Deuteronomy",
    "Joshua",
    "Judges",
    "Ruth",
    "1 Samuel",
    "2 Samuel",
    "1 Kings",
    "2 Kings",
    "1 Chronicles",
    "2 Chronicles",
    "Ezra",
    "Nehemiah",
    "Esther",
    "Job",
    "Psalms",
    "Proverbs",
    "Ecclesiastes",
    "Song of Solomon",
    "Isaiah",
    "Jeremiah",
    "Lamentations",
    "Ezekiel",
    "Daniel",
    "Hosea",
    "Joel",
    "Amos",
    "Obadiah",
    "Jonah",
    "Micah",
    "Nahum",
    "Habakkuk",
    "Zephaniah",
    "Haggai",
    "Zechariah",
    "Malachi",
    "New Testament",
    "Matthew",
    "Mark",
    "Luke",
    "John",
    "Acts",
    "Romans",
    "1 Corinthians",
    "2 Corinthians",
    "Galatians",
    "Ephesians",
    "Philippians",
    "Colossians",
    "1 Thessalonians",
    "2 Thessalonian",
    "1 Timothy",
    "2 Timothy",
    "Titus",
    "Philemon",
    "Hebrews",
    "James",
    "1 Peter",
    "2 Peter",
    "1 John",
    "2 John",
    "3 John",
    "Jude",
    "Revelation",
    "1 Esdras",
    "2 Esdras",
    "Tobit",
    "Judith",
    "Additions to the Book of Esther",
    "Wisdom of Solomon",
    "Prologue to Wisdom of Jesus Son of Sirach",
    "Wisdom of Jesus Son of Sirach",
    "Baruch",
    "Letter of Jeremiah",
    "Prayer of Azariah",
    "Susanna",
    "Bel and the Dragon",
    "Prayer of Manasseh",
    "1 Maccabees",
    "2 Maccabees"
]

def find_book(book)
    downbook = Abbrev::abbrev(BOOKS.map {|b| b.downcase})[book.downcase]
    if downbook
        BOOKS.detect { |b| b.downcase == downbook }
    end
end

def parse_body(body)
    i = body.index('<h3>') or return
    i = body.index('<h3>', i + 1) or return
    j = body.index('</body>', i) or return
    strip_html(body[i...j]).gsub(/\[ (\d+) \]/, '[\\1]')
end
SYNTAX = 'Usage: !kjv <book> <chapter>:<verse>[-<verse>]'

m = match_args(/([12]?[a-zA-Z ]+)\s+(\d+):(\d+)(?:-(\d+))?/,
          '<book> <chapter>:<verse>[-<verse>]')
abook, chap, sverse, everse = m[1], m[2], m[3], m[4]

unless (book = find_book(abook))
  exit_reply "#{abook} is not a book of the bible"
end

body = http_get("http://www.hti.umich.edu/cgi/k/kjv/kjv-idx?type=citation&book=#&chapno=#&startverse=#&endverse=#", book, chap, sverse, everse)
if (res = parse_body(body))
  reply res
else
  reply "error parsing kjv citation for #{$args}"
end
