suite 'Extractor', ->
  extractor = require("../src/extractor")
  cheerio = require("cheerio")

  test 'exists', ->
    ok extractor

  test 'returns a blank title', ->
    doc = cheerio.load("<html><head><title></title></head></html>")
    title = extractor.title(doc)
    eq title, ""

  test 'returns a simple title', ->
    doc = cheerio.load("<html><head><title>Hello!</title></head></html>")
    title = extractor.title(doc)
    eq title, "Hello!"

  test 'returns a simple title chunk', ->
    doc = cheerio.load("<html><head><title>This is my page - mysite</title></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns a soft title chunk without truncation', ->
      doc = cheerio.load("<html><head><title>University Budgets: Where Your Fees Go | Top Universities</title></head></html>")
      title = extractor.softTitle(doc)
      eq title, "University Budgets: Where Your Fees Go"

  test 'prefers the meta tag title', ->
    doc = cheerio.load("<html><head><title>This is my page - mysite</title><meta property=\"og:title\" content=\"Open graph title\"></head></html>")
    title = extractor.title(doc)
    eq title, "Open graph title"

  test 'falls back to title if empty meta tag', ->
    doc = cheerio.load("<html><head><title>This is my page - mysite</title><meta property=\"og:title\" content=\"\"></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns another simple title chunk', ->
    doc = cheerio.load("<html><head><title>coolsite.com: This is my page</title></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns a title chunk without &#65533;', ->
    doc = cheerio.load("<html><head><title>coolsite.com: &#65533; This&#65533; is my page</title></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns the first title;', ->
    doc = cheerio.load("<html><head><title>This is my page</title></head><svg xmlns=\"http://www.w3.org/2000/svg\"><title>svg title</title></svg></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'handles missing favicons', ->
    doc = cheerio.load("<html><head><title></title></head></html>")
    favicon = extractor.favicon(doc)
    eq undefined, favicon

  test 'returns the article published meta date', ->
    doc = cheerio.load("<html><head><meta property=\"article:published_time\" content=\"2014-10-15T00:01:03+00:00\" /></head></html>")
    date = extractor.date(doc)
    eq date, "2014-10-15T00:01:03+00:00"

  test 'returns the article dublin core meta date', ->
      doc = cheerio.load("<html><head><meta name=\"DC.date.issued\" content=\"2014-10-15T00:01:03+00:00\" /></head></html>")
      date = extractor.date(doc)
      eq date, "2014-10-15T00:01:03+00:00"

  test 'returns the date in the <time> element', ->
    doc = cheerio.load("<html><head></head><body><time>24 May, 2010</time></body></html>")
    date = extractor.date(doc)
    eq date, "24 May, 2010"

  test 'returns the date in the <time> element datetime attribute', ->
    doc = cheerio.load("<html><head></head><body><time datetime=\"2010-05-24T13:47:52+0000\">24 May, 2010</time></body></html>")
    date = extractor.date(doc)
    eq date, "2010-05-24T13:47:52+0000"

  test 'returns the copyright line element', ->
    doc = cheerio.load("<html><head></head><body><div>Some stuff</div><ul><li class='copyright'><!-- // some garbage -->© 2016 The World Bank Group, All Rights Reserved.</li></ul></body></html>")
    copyright = extractor.copyright(doc)
    eq copyright, "© 2016 The World Bank Group, All Rights Reserved."

  test 'returns the article published meta author', ->
    doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"Joe Bloggs\" /></head></html>")
    author = extractor.author(doc)
    eq JSON.stringify(author), JSON.stringify(["Joe Bloggs"])

  test 'returns the meta author', ->
    doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"Sarah Smith\" /><meta name=\"author\" content=\"Joe Bloggs\" /></head></html>")
    author = extractor.author(doc)
    eq JSON.stringify(author), JSON.stringify(["Sarah Smith", "Joe Bloggs"])

