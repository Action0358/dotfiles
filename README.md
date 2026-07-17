# dotfiles

自分の開発環境設定ファイル

## 構成

| ディレクトリ | ツール | 設定ファイル |
|-------------|--------|-------------|
| `nvim/` | NeoVim | `init.lua` |
| `ghostty/` | Ghostty | `config` |
| `herdr/` | herdr | `config.toml` |

## 設定内容

### NeoVim (`nvim/init.lua`)

- カラーテーマ: tokyonight-night
- ファイルツリー: neo-tree（フローティング表示・隠しファイル表示・リアルタイム監視・パスコピー機能）
- ファジーファインダー: Telescope（幅95%・高さ90%のフローティング表示）
- LSP: Mason（Go / TypeScript / Tailwind CSS / CSS / HTML）
- 補完: nvim-cmp
- Git連携: gitsigns
- キーマップ可視化: which-key

### Ghostty (`ghostty/config`)

- フォント: JetBrainsMono Nerd Font / 14px
- テーマ: tokyonight

### herdr (`herdr/config.toml`)

- ペイン移動: `prefix+h/j/k/l`（Vim 風、デフォルト）
- スクロールバック編集: `prefix+e`（nvim で開き、`v` 選択・`y` コピー）
- エージェントパネル: spaces 順で表示

## セットアップ

```bash
cp nvim/init.lua ~/.config/nvim/init.lua
cp ghostty/config ~/.config/ghostty/config
cp herdr/config.toml ~/.config/herdr/config.toml
```

## 依存関係

- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)

```bash
brew install --cask font-jetbrains-mono-nerd-font
```
