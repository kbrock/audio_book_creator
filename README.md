# AudioBookCreator

[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]
[![Dependency Status][DS img]][Dependency Status]
[![Code Climate][CC img]][Code Climate]
[![Coverage Status][CS img]][Coverage Status]

[Gem Version]: https://rubygems.org/gems/audio_book_creator
[Build Status]: https://travis-ci.org/kbrock/audio_book_creator
[travis pull requests]: https://travis-ci.org/kbrock/audio_book_creator/pull_requests
[Dependency Status]: https://gemnasium.com/kbrock/audio_book_creator
[Code Climate]: https://codeclimate.com/github/kbrock/audio_book_creator
[Coverage Status]: https://coveralls.io/r/kbrock/audio_book_creator

[GV img]: https://badge.fury.io/rb/audio_book_creator.png
[BS img]: https://travis-ci.org/kbrock/audio_book_creator.png
[DS img]: https://gemnasium.com/kbrock/audio_book_creator.png
[CC img]: https://codeclimate.com/github/kbrock/audio_book_creator.png
[CS img]: https://coveralls.io/repos/kbrock/audio_book_creator/badge.png?branch=master


## Description

This takes html files and creates a chapterized audiobook.
  It leverages Apple's speak command and audio book binder

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

audio_book_creator http://bookurl.com/greak_book/ --body '.content p' --link 'a.page' --chapter 'a.chapter'

it will spider the files referenced by the url and create the following:

pages.db
the_great_book.mpa
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
