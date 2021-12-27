# qmmp-macosintegration

A plug-in for [Qmmp](http://qmmp.ylsoftware.com/) that provides better
integration with the MacOS desktop (tested with Monterey on arm64).

## Installation

Your mileage will vary:

```sh
mkdir build && cd build

# set up pkg-config to look for a qmmp installed into ~/opt/qmmp (I built mine
# from source), and also for qt@5 (installed via homebrew)
export PKG_CONFIG_PATH=~/opt/qmmp/lib/pkgconfig:/opt/homebrew/opt/qt@5/lib/pkgconfig

cmake ..
make
make install
```

## Usage

Start Qmmp, go to the settings, and enable the `MacOS Integration` plug-in
(listed in _General_).

## Contributing

1. Fork it (<https://github.com/nilsding/qmmp-macosintegration/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
