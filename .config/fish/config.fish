if status is-interactive # Commands to run in interactive sessions can go here

    # ============================================
    # PROMPT & GREETING SETTINGS
    # ============================================
    set fish_greeting  # No greeting on startup
    
    # Use starship for a sexy prompt
    starship init fish | source
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # ============================================
    # SYNTAX HIGHLIGHTING - Ocean Dark Theme (Enhanced)
    # ============================================
    # Premium colors matching Starship's ocean_dark palette with enhanced vibrancy
    
    # Command colors
    set fish_color_command '#9ece6a'        # Vibrant green - commands stand out
    set fish_color_builtin '#7dcfff'        # Bright cyan - built-in commands
    set fish_color_function '#7aa2f7'       # Bright blue - functions
    
    # Keywords and syntax
    set fish_color_keyword '#f7768e'        # Vibrant red - keywords pop
    set fish_color_statement '#bb9af7'      # Bright purple - statements
    
    # Text and literals
    set fish_color_normal '#c0caf5'         # Light blue - normal text
    set fish_color_quote '#9ece6a'          # Green - quoted strings
    set fish_color_string '#9ece6a'         # Green - unquoted strings
    
    # Operators and special chars
    set fish_color_operator '#2ac3de'       # Bright cyan - operators
    set fish_color_redirection '#7aa2f7'    # Bright blue - redirections
    set fish_color_end '#c678dd'            # Magenta - end markers
    
    # Comments and annotations
    set fish_color_comment '#565f89'        # Muted gray - comments
    set fish_color_annotation '#9ece6a'     # Green - annotations
    
    # Errors and validation
    set fish_color_error '#f7768e'          # Vibrant red - errors
    set fish_color_invalid '#f7768e'        # Red - invalid syntax
    
    # Search and paths
    set fish_color_valid_path '#9ece6a'     # Green - valid paths
    set fish_color_search_match 'bg:#bb9af7 fg:#c0caf5'  # Purple bg - search matches
    
    # Auto-suggestions
    set fish_color_autosuggestion '#414868' # Subtle gray - non-intrusive suggestions
    
    # Escape sequences
    set fish_color_escape '#2ac3de'         # Cyan - escape sequences
    set fish_color_param '#7dcfff'          # Bright cyan - parameters
    
    # Selection and paging
    set fish_color_selection 'bg:#7aa2f7 fg:#16161e'  # Blue bg, dark fg - high contrast
    
    # Paging colors (completions menu)
    set fish_pager_color_prefix '#9ece6a'                    # Green prefix
    set fish_pager_color_completion '#c0caf5'               # Light blue completions
    set fish_pager_color_description '#414868'              # Muted gray descriptions
    set fish_pager_color_progress 'bg:#bb9af7 fg:#c0caf5'   # Purple progress bar
    set fish_pager_color_background '#1a1b26'               # Dark background
    set fish_pager_color_secondary '#2ac3de'                # Cyan secondary

    # ============================================
    # ALIASES - Enhanced with new tools
    # ============================================
    # System
    alias pamcan='pacman'
    alias ls='eza --icons --color=always --group-directories-first'
    alias la='eza -la --icons --color=always --group-directories-first'
    alias ll='eza -l --icons --color=always --group-directories-first'
    alias lt='eza --tree --icons --color=always --group-directories-first'
    alias ltt='eza --tree --depth=2 --icons --color=always'
    alias clear="printf '\033[2J\033[3J\033[1;1H'"
    alias q='qs -c ii'
    
    # File operations
    alias cat='bat --theme=Monokai\ Extended'
    alias grep='grep --color=always'
    alias diff='diff --color=always'
    alias find='fd'
    alias du='dust'
    alias ps='procs'
    
    # Directory navigation
    alias cd..='cd ..'
    alias cd...='cd ../..'
    alias cd....='cd ../../..'
    alias .='pwd'
    alias ..='cd ..'
    
    # System info
    alias nf='neofetch'
    alias sysinfo='neofetch'
    alias freq='watch -n 1 "lscpu | grep MHz"'
    
    # ============================================
    # ABBREVIATIONS - Quick expansions with eog
    # ============================================
    # Git workflow
    abbr -a g git
    abbr -a gs 'git status'
    abbr -a ga 'git add'
    abbr -a gaa 'git add .'
    abbr -a gc 'git commit -m'
    abbr -a gp 'git push'
    abbr -a gpl 'git pull'
    abbr -a gd 'git diff'
    abbr -a gl 'git log'
    abbr -a gb 'git branch'
    abbr -a gco 'git checkout'
    abbr -a gm 'git merge'
    abbr -a gr 'git reset'
    abbr -a gst 'git stash'
    
    # Pacman
    abbr -a pacin 'pacman -S'
    abbr -a pacrem 'pacman -R'
    abbr -a pacsearch 'pacman -Ss'
    abbr -a pacupd 'pacman -Syu'
    
    # Common shortcuts
    abbr -a nf 'neofetch'
    abbr -a v 'nvim'
    abbr -a vi 'nvim'
    abbr -a py 'python'
    abbr -a yt 'youtube-dl'
    abbr -a weather 'curl wttr.in'
    
    # ============================================
    # KEY BINDINGS - Vim mode & custom shortcuts
    # ============================================
    set fish_bind_mode insert
    
    # Enable vi key bindings
    fish_vi_key_bindings
    
    # Custom keybindings
    bind -M insert \cf forward-char
    bind -M insert \cb backward-char
    bind -M insert \ce end-of-line
    bind -M insert \ca beginning-of-line
    
    # Alt+n for new window (if using tmux)
    bind \en 'tmux new-window'
    bind \ew 'tmux kill-pane'
    
    # ============================================
    # ENVIRONMENT VARIABLES
    # ============================================
    # Editor
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    
    # Colors
    set -gx CLICOLOR 1
    set -gx CLICOLOR_FORCE 1
    
    # FZF settings
    set -gx FZF_DEFAULT_COMMAND 'fd --type f'
    set -gx FZF_DEFAULT_OPTS '--height 40% --reverse --border'
    
    # Less colors
    set -gx LESS '-R'
    set -gx LESSOPEN '| bat --color=always %s'
    
    # Node version manager
    if type -q nvm
        nvm use default --silent
    end
    
    # ============================================
    # COMPLETIONS & CACHING
    # ============================================
    # Enable completion caching for faster startup
    set -g fish_complete_cache_mode adaptive
    
    # Lazy-load completions
    if status is-interactive
        complete -c pacman -f
        complete -c git -f
        complete -c nvim -f
    end
    
    # ============================================
    # CUSTOM FUNCTIONS
    # ============================================
    
    # Quick cd to recent directories
    function cdp --description 'Change to project directory'
        set -l project (find ~/Projects -maxdepth 2 -type d | fzf --preview 'ls -la {}')
        test -n "$project" && cd $project
    end
    
    # Git clone and cd
    function gcnd --description 'Clone repo and cd into it'
        if test (count $argv) -eq 0
            echo "Usage: gcnd <git-url>"
            return 1
        end
        set -l repo_name (basename $argv[1] .git)
        git clone $argv[1]
        cd $repo_name
    end
    
    # Create directory and cd into it
    function mkcd --description 'Create and cd into directory'
        mkdir -p $argv
        cd $argv[-1]
    end
    
    # Extract any archive
    function extract --description 'Extract any archive type'
        if test -f $argv[1]
            switch $argv[1]
                case '*.tar.bz2'
                    tar xjf $argv[1]
                case '*.tar.gz'
                    tar xzf $argv[1]
                case '*.bz2'
                    bunzip2 $argv[1]
                case '*.rar'
                    unrar x $argv[1]
                case '*.gz'
                    gunzip $argv[1]
                case '*.tar'
                    tar xf $argv[1]
                case '*.tbz2'
                    tar xjf $argv[1]
                case '*.tgz'
                    tar xzf $argv[1]
                case '*.zip'
                    unzip $argv[1]
                case '*.Z'
                    uncompress $argv[1]
                case '*.7z'
                    7z x $argv[1]
                case '*'
                    echo "Unable to extract $argv[1]"
                    return 1
            end
        else
            echo "$argv[1] is not a valid file"
            return 1
        end
    end
    
    # Show disk usage with better formatting
    function dusage --description 'Show disk usage in human format'
        du -sh $argv[1] | sort -hr
    end
    
    # Quick grep with fzf
    function fgrep --description 'Search and preview with fzf'
        grep -r $argv[1] . --include="*.{$argv[2]}" 2>/dev/null | \
        fzf --preview 'echo {} | cut -d: -f1,2 | head -50'
    end
    
    # Show command execution time
    function fish_postexec --description 'Show command duration'
        set -l last_status $status
        set -l cmd_duration_ms $CMD_DURATION
        
        # Show duration for commands taking >500ms
        if test $cmd_duration_ms -gt 500
            set -l duration_sec (math "$cmd_duration_ms / 1000")
            echo -ne "\033[90m⏱  $duration_sec s\033[0m"
        end
        
        return $last_status
    end
    
    # Simple weather
    function weather --description 'Show weather info'
        curl -s wttr.in?format=3
    end
    
    # Quick note taking
    function note --description 'Quick note to file'
        if test (count $argv) -eq 0
            cat ~/.notes
        else
            echo $argv >> ~/.notes
        end
    end
    
    # Color ls output
    function ls --description 'List files with colors'
        eza --icons --color=always --group-directories-first $argv
    end
    
    # ============================================
    # PLUGIN SYSTEM (conf.d/)
    # ============================================
    # Auto-load conf.d scripts
    if test -d ~/.config/fish/conf.d
        for file in ~/.config/fish/conf.d/*.fish
            source $file
        end
    end
    
end
