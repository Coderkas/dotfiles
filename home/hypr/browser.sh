#!/usr/bin/env bash
path=$(fd "bookmarks.sqlite" "$(fd -t d "default" ~/.mozilla -d 2)")
cp "$path" ~/.cache/ff-bookmarks-cache.sqlite
res=$(sqlite3 -readonly ~/.cache/ff-bookmarks-cache.sqlite "SELECT urls.url FROM items LEFT JOIN urls ON items.urlId=urls.id WHERE items.isDeleted == 0 AND urls.url NOT LIKE '%mangadex%';" | rofi -dmenu)

if [[ -n "$res" ]]; then
    if [[ ! $res =~ ^http* ]]; then
        res="https://duckduckgo.com/?q=$res"
    fi

    firefox "$res"
fi
