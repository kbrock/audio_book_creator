# AudioBookCreator

# << ARCHIVED >>

## Description

This takes html files and creates a chapterized audiobook.
  It leverages Apple's speak command and audio book binder

Apple has since modified the interface and makes it much more difficult to sync to your phone.
It has made this not useful to me, or probably anyone really.

But it was a good exploration into 100% code testing. Mutant testing means you compare every
node in an if clause and ensure every boundery number matters. did you do a gsub instead of a sub?
Yea that kind off stuff. Similar to Heckle from portland.rb group

It was fun but archiving. Happy coding all

## Goals

1. create an audio book.
2. explore [mutant](https://github.com/mbj/mutant) usage and full test coverage.
3. explore [functional core imperative shell](https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell)
4. explore local queued components
4. explore javascript plugins that leverage local daemons [TODO]
## Installation

Download [audio book binder][], link the executable into the path, and install gem. The current app store version of the application does not have the cli available.

    $ ln -s /Applications/AudioBookBinder.app/Contents/MacOS/abbinder /usr/local/bin/
    $ gem install audio_book_creator

[audio book binder]: http://bluezbox.com/audiobookbinder.html

## Usage

```
audio_book_creator http://bookurl.com/greak_book/ --body '.content p' --link 'a.page' --chapter 'a.chapter'
```

it will spider the files referenced by the url and create the following:

pages.db
the_great_book.m4b
the_great_book/chapter1.txt
the_great_book/chapter1.mpg
the_great_book/chapter2.txt
the_great_book/chapter2.mpg
the_great_book/chapter3.txt
the_great_book/chapter3.mpg

If you tend to visit bookurl.com often, then setup the values as defaults

```
audio_book_creator http://bookurl.com/greak_book/ --body '.content p' --link 'a.page' --chapter 'a.chapter' --default
audio_book_creator http://bookurl.com/greak_book2/
```

Since `great_book2` is at the same domain, it will reuse the `--body`, `--link` and `--chapter` path selectors.

the_great_book2.m4b
the_great_book2/chapter1.txt
the_great_book2/chapter1.mpg
the_great_book2/chapter2.txt
the_great_book2/chapter2.mpg


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
