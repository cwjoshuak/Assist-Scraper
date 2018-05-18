# AssistScraper (WIP)

### Under no circumstances is this efficient, but it works (?)

## Build Instructions
```
$ git clone https://github.com/cwjoshuak/Assist-Scraper.git
$ cd Assist-Scraper
$ swift build
$ swift run
```

### Note
If you want to run it in Xcode, make sure that you are trying to build and run the AssistScraper executable.

## Program Flow

1. Loads welcome page -> stores all origin institutions
2. Loads one origin institution -> stores all destination institutions
3. Loads one destination institution -> stores all major codes
4. Loads one major agreement -> [needs to be parsed]
5. Parsed data -> stored in custom class -> file
####  -Assuming 16-17 year agreement for now
