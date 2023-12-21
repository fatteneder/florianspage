# the funcction hfun_blogposts below as well as the organization of blogs (see blog/index.md)
# was taken from https://github.com/abhishalya/abhishalya.github.io


using Dates

"""
    {{blogposts}}

Plug in the list of blog posts contained in the `/blog/` folder.
"""
@delay function hfun_blogposts()
    today = Dates.today()
    curyear = year(today)
    curmonth = month(today)
    curday = day(today)

    list = readdir("blog")
    filter!(f -> endswith(f, ".md"), list)
    sorter(p) = begin
        ps  = splitext(p)[1]
        url = "/blog/$ps/"
        surl = strip(url, '/')
        pubdate = pagevar(surl, :published)
        if isnothing(pubdate)
            return Date(Dates.unix2datetime(stat(surl * ".md").ctime))
        end
        return Date(pubdate, dateformat"d U Y")
    end
    sort!(list, by=sorter, rev=true)

    io = IOBuffer()
    write(io, """<ul class="blog-posts">""")
    for (i, post) in enumerate(list)
        if post == "index.md"
            continue
        end
        ps  = splitext(post)[1]
        write(io, "<li><span><i>")
        url = "/blog/$ps/"
        surl = strip(url, '/')
        title = pagevar(surl, :title)
        pubdate = pagevar(surl, :published)
        if isnothing(pubdate)
            date    = "$curyear-$curmonth-$curday"
        else
            date    = Date(pubdate, dateformat"d U Y")
        end
        write(io, """$date</i></span><a href="$url">$title</a>""")
    end
    write(io, "</ul>")
    return String(take!(io))
end
