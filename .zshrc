# User
export User='fujikawa-hiroki'

# Language
export LANG=ja_JP.UTF-8

# Editor
export EDITOR=vim
bindkey -v

# git(RPROMPTに表示)
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%m%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '%F{magenta}[%b|%a]%f'
zstyle ':vcs_info:git*+set-message:*' hooks git-push-status git-pull-status git-untracked

# untrackedなファイルがある場合は赤い?をつける
+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then
        hook_com[staged]+='%F{red}?'
    fi
}

# リモートより先行している場合は(↑n)を表示
+vi-git-push-status() {
  local ahead
  ahead=$(command git rev-list origin/`git rev-parse --abbrev-ref HEAD`..`git rev-parse --abbrev-ref HEAD` 2>/dev/null \
   | wc -l \
   | tr -d ' ')
  if [[ "$ahead" -gt 0 ]]; then
    hook_com[misc]+="%F{cyan}(↑${ahead})%f"
  fi
}

# リモートより遅れている場合は(↓n)を表示
+vi-git-pull-status() {
  local behind
  behind=$(command git rev-list `git rev-parse --abbrev-ref HEAD`..origin/`git rev-parse --abbrev-ref HEAD` 2>/dev/null \
   | wc -l \
   | tr -d ' ')
  if [[ "$behind" -gt 0 ]]; then
    hook_com[misc]+="%F{cyan}(↓${behind})%f"
  fi
}

precmd () { vcs_info }
RPROMPT=$RPROMPT'${vcs_info_msg_0_}'

# Util
autoload -Uz colors
colors

if [ -e /usr/local/share/zsh-completions ]; then
    fpath=(/usr/local/share/zsh-completions $fpath)
fi

setopt no_beep
setopt ignore_eof
setopt extended_glob

# スペルミス系
setopt correct
setopt correct_all

# Auto Cd => cdで移動後にlsをオートで実行
setopt auto_cd
setopt auto_pushd
function chpwd() { ls -laG }

# completation
# コマンド補完、超便利
autoload -U compinit
compinit -u
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion::complete:*' use-cache true
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR
zstyle ':completion:*' list-colors ''

# predict => 過去コマンドから推測して変換
# 基本onにしておくがコマンド途中書き換え時に後ろが消えて困るので
# キーバインドでoffにもできるようにしておく
autoload predict-on
predict-on
zle -N predict-on
zle -N predict-off
bindkey '^Po' predict-on
bindkey '^Pf' predict-off

# Prompt(見えにくいので1行空白込)
PROMPT="
%{${fg[yellow]}%}[20%D %*]%{${reset_color}%} %{${fg[green]}%}%n%{${reset_color}%} %~
%# "

# history
# キーバインドでいろいろと検索可能になってるはず
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history
setopt extended_history
setopt hist_ignore_space
setopt hist_no_store
setopt hist_verify
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^b" history-beginning-search-forward-end

# Alias
# cp,mv,rmなどは確認オプションをつける
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# ls, grepはカラーをつける
alias ls='ls -laG'
alias grep='grep --color=always'

# historyは1件目から全て時刻含みで表示させる
alias history='history -f -d 1'

# zshrc編集＆再度読み込み用
alias zshedit='vim ~/.zshrc'
alias zshsource='source ~/.zshrc'

# ターミナルのrestart
alias restart='exec $SHELL -l'

alias tf='tail -f'

# ~~Git関連は消しました~~

# Tree
# Windowsのduコマンド的なやつ
alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'"

# clipboard copy
# `ls -l C`のように使用することで結果をクリップボードにコピー可能
# ファイル作成→ファイル開く→自分でコピーが面倒だったので追加
if which pbcopy >/dev/null 2>&1 ; then 
    alias -g C='| pbcopy'
elif which xsel >/dev/null 2>&1 ; then 
    alias -g C='| xsel --input --clipboard'
elif which putclip >/dev/null 2>&1 ; then 
    alias -g C='| putclip'
fi

# finder <-> terminal
# ターミナルでfinderコマンドを使用することで、カレントディレクトリでfinderを開ける
# finderを開いているときにcdfコマンドを使用することでターミナル側のパス移動可能
# => CUI, GUIの連携が容易になる
alias finder='open .'
cdf () {
  target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
  if [ "$target" != "" ]
  then
    cd "$target"
    pwd
  else
    echo 'No Finder window found' >&2
  fi
}

# keybind
# `clear`打つのが面倒なのでキーバインド化
function key-clear() {
  clear
  zle reset-prompt
}
zle -N key-clear
bindkey '^K' key-clear

# ^N? -> npm run ~~~
# 毎回毎回`npm run start`打つのが面倒なのでキーバインド化
function npm-run-start() {
  npm run start
  zle reset-prompt
}
zle -N npm-run-start
bindkey '^Ns' npm-run-start

function npm-run-build() {
  npm run build
  zle reset-prompt
}
zle -N npm-run-build
bindkey '^Nb' npm-run-build

function npm-run-test() {
  npm run test
  zle reset-prompt
}
zle -N npm-run-test
bindkey '^Nt' npm-run-test

# anyenv
eval "$(anyenv init -)"
