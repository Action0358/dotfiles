# dotfiles

自分の開発環境設定ファイル

## 構成

| ディレクトリ | ツール | 設定ファイル |
|-------------|--------|-------------|
| `nvim/` | NeoVim | `init.lua` |
| `ghostty/` | Ghostty | `config` |
| `tmux/` | tmux | `tmux.conf` |

## 設定内容

### NeoVim (`nvim/init.lua`)

- カラーテーマ: tokyonight-night
- ファイルツリー: neo-tree（隠しファイル表示・リアルタイム監視・パスコピー機能）
- ファジーファインダー: Telescope
- LSP: Mason（Go / TypeScript / Tailwind CSS / CSS / HTML）
- 補完: nvim-cmp
- Git連携: gitsigns
- キーマップ可視化: which-key

### Ghostty (`ghostty/config`)

- フォント: JetBrainsMono Nerd Font / 14px
- テーマ: tokyonight

### tmux (`tmux/tmux.conf`)

- 新規セッション作成時に右側ペインを自動分割（横幅40%）

## セットアップ

```bash
cp nvim/init.lua ~/.config/nvim/init.lua
cp ghostty/config ~/.config/ghostty/config
cp tmux/tmux.conf ~/.config/tmux/tmux.conf
```

## 依存関係

- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)

```bash
brew install --cask font-jetbrains-mono-nerd-font
```
