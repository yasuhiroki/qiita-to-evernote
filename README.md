# qiita-to-evernote

Qiitaでストックした記事を、EvernoteのノートにするためのRakefileです。

まだ完璧ではありませんので、改善中です。

# 動作環境

当方 `ruby 2.2.1p85` で動作確認をしております。

# Required

* `gem 'qiita' '= 1.2.0'`
* `gem 'evernote-thrift'`
* `gem 'oga'`
* `gem 'dotenv'`

# 使い方

```
$ git clone git@github.com:yasuhiroki/qiita-to-evernote.git
$ bundle install --path vendor/bundle
$ bundle exec rake init
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
$ bundle exec rake qiita:stock:to:evernote
ドメイン取得からDDNS設定まで is exist. skip.
いちいちbundle execしたくない 決定版 is exist. skip.

(中略)

Created Javascriptでオブジェクト指向するときに覚えておくべきこと in evernote.
Created pacoでソースビルドをパッケージっぽく管理する in evernote.
```

* tokenを、dotenvで管理しています。
* Qiitaの記事名が、ノートのタイトルになります。

# LICENSE

MIT

# 課題

詳しくは、Issueを参考にして下さい。
