# macht-sinn

Ergibt das Sinn?

## Description

This script generates a Blacklist for ad- and malwareblocking.
Since this script needs write-access to the hostfile defined in $ADNAME, root-privileges are necessary.

## Installation

0. Change into the target Git directory
0. git clone https://github.com/GHCrosser/macht-sinn.git
0. Eventually edit $ADURL and $ADNAME to your needs
0. Fetch the blocklist with 'ad_update.sh -c'
0. Enjoy an almost ad-free Internet

## Usage

`ad_update.sh {option}`
* `-c || --client` : Start to generate the Blacklists in $ADNAME
* `-v || --version` : Print the version
* `-h || --help` : Print the help message

## Contributing

0. Fork it!
0. Create your feature branch: `git checkout -b my-new-feature`
0. Commit your changes: `git commit -am 'Add some feature'`
0. Push to the branch: `git push origin my-new-feature`
0. Submit a pull request :)

## History

Version 0.1, 29.10.2015: Initial Release

## Credits

[@GHCrosser](https://github.com/GHCrosser)
[@urgemerge](https://github.com/urgemerge)
[@n0wi](https://github.com/n0wi)

[Contributors](https://github.com/GHCrosser/macht-sinn/graphs/contributors)

## License

[GNU General Public License, Version 3](LICENSE)
