[![Build Status](https://travis-ci.org/yasuhiroki/qiita-to-evernote.svg?branch=master)](https://travis-ci.org/yasuhiroki/qiita-to-evernote)

# Qiita2Evernote

Qiitaでストックした記事を、EvernoteのノートにするためのCLIツールです。

## Installation

```sh
$ gem install qiita2evernote
```

## Usage

```sh
$ q2e init
What is your qiita API token?
  - If you have not API token, let's get it from [https://qiita.com/settings/applications].
your id: yasuhiroki
token: Your Qiita API Token

What is your evernote token?
  - If you have not token, let's get it from [https://www.evernote.com/api/DeveloperToken.action].
token: Your Evernote NoteStore API Token
note store: Your Evernote NoteStore URL

Evernote default notebook
default notebook: Your Default NoteBook Name

$ q2e q2e
ドメイン取得からDDNS設定まで is exist. skip.
いちいちbundle execしたくない 決定版 is exist. skip.

(中略)

Created Javascriptでオブジェクト指向するときに覚えておくべきこと in evernote.
Created pacoでソースビルドをパッケージっぽく管理する in evernote.
```

* tokenを、dotenvで管理しています。
* Qiitaの記事名が、ノートのタイトルになります。

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yasuhiroki/qiita2evernote. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Q2e project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yasuhiroki/qiita2evernote/blob/master/CODE_OF_CONDUCT.md).
