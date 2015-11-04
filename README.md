# macht-sinn
Ergibt das Sinn?

## Description

This script generates a Blacklist for ad- and malwareblocking.
Since this script needs write-access to the hostfile defined in $ADNAME, root-privileges are necessary.

## Installation

1. Change into the target Git directory
2. git clone https://github.com/GHCrosser/macht-sinn.git
3. Eventually edit $ADURL and $ADNAME to your needs
4. Fetch the blocklist with 'ad_update.sh -c'
5. Enjoy an almost ad-free Internet

## Usage

ad_update.sh {option}
-c || --client      Start to generate the Blacklists in $ADNAME
-v || --version     Print the version
-h || --help        Print the help message

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :)

## History

Version 0.1, 29.10.2015:
    - Initial Release

## Credits

[@GHCrosser]
[@urgemerge]
[@n0wi]

## License

[GNU General Public License, Version 3](LICENSE)
