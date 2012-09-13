Up2date
=======

説明
----

up2date は vim のプラグインを管理するためのプラグインです。

この種類のプラグインとして有名なものに Vundle, Neobundle, VAM, 等があります。

特徴
----

 - 更新対象の指定は .vimrc のコメントとしてプラグインのURLを記述
 - URL から使用する バージョン管理システムを推測
 - オプションでブランチ、リビジョン、チェックアウトディレクトリなどを指定可能
 - git, mercurial, subversion に対応
 - [AsyncCommand](https://github.com/pydave/AsyncCommand) を利用することで、並列にアップデートが可能

使い方
------

`~/.vimrc` (`g:up2date_source_path` で変更可能) に記述された
`BUNDLE: <URL>` で始まる行を書きます。
コマンドではないので、コメントアウトしておかないと
Vim がロードした際にエラーとなるのでご注意ください。

    " BUNDLE: https://github.com/sgur/up2date.vim.git

その後、`:Up2date` コマンドを実行します。

コマンド
--------

### `:Up2date`

~/.vimrc に記述されている `BUNDLE: ...` 行を全て読み取り、更新します。

### `:Up2date <プラグイン1> <プラグイン2> ...`

個別に更新したい場合はプラグイン名を指定してコマンドを実行します。

Asynccommand がインストールされており、なおかつ指定したプラグインの数が
`g:up2date_max_workers` 以下の場合 (デフォルト 2)、更新チェックの完了を待たず
に Vim の操作が可能です。

### `:Up2dateAtCursor`

カーソル下の `BUNDLE: ...` の記述を読み取り、更新します。

Asynccommand がインストールされている場合、
更新チェックの完了を待たずに Vim の操作が可能です。

### `:Up2dateStatus`

`~/.vim/bundle` 以下のプラグインのうち、以下のものを表示します。

 - Uninstalled: `~/.vimrc` に `BUNDLE: ...` が記述されているが、
   実際にはインストールされていないもの
 - Unlisted: `~/.vim/bundle` 以下にプラグインが存在するが、
   `~/.vimrc` に `BUNDLE: ...` の記述がないもの

オプション
----------

以下のように URL のみを指定した場合、チェックアウトで作成されるフォルダは、
各バージョン管理システムのデフォルトとなります。

    " BUNDLE: https://github.com/sgur/up2date.vim.git

また、上記 `BUNDLE:` 行へ指定できるオプションとしては以下のものがあります。

使用されるバージョン管理システムによっては指定しても無効となるものがあります。

### チェックアウト対象のリビジョンの指定

`@` に続けて、チェックアウト対象とするリビジョンを指定する

### チェックアウト対象のブランチの指定

`+` に続けて、チェックアウト対象とするブランチを指定する

### チェックアウト先フォルダの指定

`/` に続けて、チェックアウト先のフォルダ名を指定する。

### バージョン管理システムの指定

`-` に続けて、使用するバージョン管理システムを指定する。

指定可能な値: `-git`, `-mercurial`, `-subversion`

例
--

vim-powerline の develop ブランチを使用する

	" BUNDLE: https://github.com/Lokaltog/vim-powerline.git +develop

subversion 管理のリポジトリから、~/.vim/bundle/autofmt へチェックアウトする

	" BUNDLE: http://vim-soko.googlecode.com/svn/trunk/autofmt/ -subversion /autofmt
