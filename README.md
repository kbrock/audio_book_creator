# AudioBookCreator

This takes html files and creates a chapterized audiobook.
  It leverages Apple's speak command and audio book binder

## Installation

Add this line to your application's Gemfile:

    gem 'audio_book_creator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install audio_book_creator

## Usage

audio_book_creator the_great_book http://bookurl.com/greak_book/

it will spider the files referenced by the url and create the following:

the_great_book.mpa
the_great_book/pages.db
the_great_book/chapter1.txt
the_great_book/chapter1.mpg
the_great_book/chapter2.txt
the_great_book/chapter2.mpg
the_great_book/chapter3.txt
the_great_book/chapter3.mpg

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
