#!/usr/bin/env bash
path=$(fd "bookmarks.sqlite" "$(fd -t d "default" ~/.mozilla -d 2)")
cp "$path" ~/.cache/ff-bookmarks-cache.sqlite
res=$(sqlite3 -readonly ~/.cache/ff-bookmarks-cache.sqlite "SELECT urls.url FROM items LEFT JOIN urls ON items.urlId=urls.id WHERE items.isDeleted == 0 AND urls.url NOT LIKE '%mangadex%';" | rofi -dmenu)

if [[ -n "$res" ]]; then
    case "$res" in
        "wiki:"*) res="https://en.wikipedia.org/w/index.php?search=${res:5}";;
        "jp:"*) res="https://jisho.org/search/${res:3}";;
        "xiny:"*) res="https://learnxinyminutes.com/${res:5}/";;
        "ani:"*) res="https://anilist.co/search/anime?search=${res:4}";;
        "yt:"*) res="https://youtube.com/results?search_query=${res:3}";;
    esac

    if [[ ! $res =~ (^http.)|([a-z]\.(de|edu|com|org|gov|net|io)) ]]; then
        res="https://duckduckgo.com/?q=$res"
    fi

    firefox "$res"
fi
