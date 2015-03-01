# Ocd

File browser for the terminal. Tested in iTerm2.

## Demo

![demo](http://fat.gfycat.com/ValuableBeautifulClumber.gif)

## Install

    git clone https://github.com/aalin/ocd.git ~/.ocd/

## Use

Add to your shells rc-file:

    export OCD_PATH="$HOME/.ocd"
    source "$OCD_PATH/bin/setup.sh"

Then, in your shell, just type `ocd`.

## Bugs

* Some files are not updated properly when scrolling.

## TODO

* Fix window resize handling.
* Fix open dialog.
* Extract drawing-stuff into it's own library.
* Configurable list of commands.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
