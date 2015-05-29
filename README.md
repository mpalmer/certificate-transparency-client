This is a Ruby client library for interacting with
[RFC6962](http://tools.ietf.org/html/rfc6962) [Certificate
Transparency](http://www.certificate-transparency.org/) servers.  It
aims to provide a complete interface for retrieving and validating tree
heads, entries, SCTs, as well as submitting certificates and precerts to a
log.

At present, it is not feature complete, however what is released is well
tested, heavily documented, and should be ready for production use.


# Installation

It's a gem:

    gem install certificate-transparency-client

There's also the wonders of [the Gemfile](http://bundler.io):

    gem 'certificate-transparency-client'

If you're the sturdy type that likes to run from git:

    rake build; gem install pkg/certificate-transparency-client-<whatever>.gem

Or, if you've eschewed the convenience of Rubygems entirely, then you
presumably know what to do already.


# Usage

To get started, instantiate a new instance of {CT::Client}:

    require 'certificate-transparency-client'

    ct = CT::Client.new "https://ct.example.org"

The URL provided should be the "base" URL for the log; that is, everything
immediately preceding the `/ct/v1/<blah>` parts of the URL when making a
complete request.

If you only provide a URL, you can retrieve things and submit entries, but
if you provide a public key, {CT::Client} will also validate signatures for
you:

    ct = CT::Client.new "https://ct.example.org",
                        :public_key => "<native or base64 key>"

To discover what you can do with an instance of {CT::Client}, see the API
docs for the {CT::Client} class.


# Contributing

Bug reports should be sent to the [Github issue
tracker](https://github.com/mpalmer/certificate-transparency-client/issues),
or [e-mailed](mailto:theshed+certificate-transparency-client@hezmatt.org). 
Patches can be sent as a Github pull request, or
[e-mailed](mailto:theshed+certificate-transparency-client@hezmatt.org).


# Licence

Unless otherwise stated, everything in this repo is covered by the following
copyright notice:

    Copyright (C) 2014,2015  Matt Palmer <matt@hezmatt.org>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License version 3, as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
