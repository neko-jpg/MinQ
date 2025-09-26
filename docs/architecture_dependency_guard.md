# レイヤ分離チェック（Dep Guard）

目的は、UI/UseCase/Repository/DB/Remote の依存方向を崩さないことです。Flutter アプリ内の `lib/` 配下では以下のルールを GitHub Actions 上で強制します。

## 監視対象と制約

| レイヤ | 許可される依存先 | 禁止される依存先 |
| --- | --- | --- |
| `lib/domain` | 標準ライブラリ／外部パッケージ | `lib/data`, `lib/presentation` |
| `lib/data` | 標準ライブラリ／外部パッケージ／`lib/domain` | `lib/presentation` |
| `lib/presentation` | 標準ライブラリ／外部パッケージ／`lib/data`／`lib/domain` | `lib/data` 以下からの逆参照は禁止 |

`tool/dep_guard.dart` がすべての Dart ファイルを走査し、禁止パス（例: `package:minq/presentation/...`）への import を検出した場合は CI で失敗します。

## 運用手順

1. 新しいレイヤ構成を追加する場合は `tool/dep_guard.dart` のルールを更新し、CI で緑になることを確認します。
2. 違反が発生した場合、リファクタリングで依存方向を修正するか、正当性がある場合はルールの例外を追記します。
3. Pull Request では GitHub Actions の `Architecture Guard` ジョブが必ず走り、依存方向が守られていることを保証します。

これにより、UI レイヤから下位レイヤへの参照のみ許可し、逆依存が混入しないよう継続的にチェックします。
