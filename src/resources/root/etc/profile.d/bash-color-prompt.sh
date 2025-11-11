# see /usr/share/doc/bash-color-prompt/README.md

## to truncate \w dirpath set:
# PROMPT_DIRTRIM=3

# only for bash
if [ -n "${BASH_VERSION}" -a -z "${bash_prompt_color_disable}" ]; then

    # enable only in interactive shell
    case $- in
        *i*) ;;
        *) return;;
    esac

    # defines PS1 for color prompt
    prompt_setup_color_ps1() {
        local colorpre='\[\e['
        local colorsuf='m\]'
        local colorreset="${colorpre}0${colorsuf}"
        PS1='${PROMPT_START@P}'"${colorpre}"'${PROMPT_COLOR}${PROMPT_HIGHLIGHT:+;$PROMPT_HIGHLIGHT}'"${colorsuf}"'${PROMPT_USERHOST@P}'"${colorreset}"'${PROMPT_SEPARATOR@P}'"${colorpre}"'${PROMPT_DIR_COLOR-${PROMPT_COLOR}}${PROMPT_HIGHLIGHT:+;$PROMPT_HIGHLIGHT}'"${colorsuf}"'${PROMPT_DIRECTORY@P}'"${colorreset}"'${PROMPT_END@P}\$'"${colorreset} "
    }

    # sets default color or $1 can override
    prompt_color() {
        if [ -n "${1:+1}" ]; then
            PROMPT_COLOR="$1"
        else
            if [ "$USER" = "root" ]; then
                PROMPT_COLOR=35
            else
                PROMPT_COLOR=32
            fi
        fi
    }

    # sets prompt highlighting
    prompt_highlight() {
        PROMPT_HIGHLIGHT=${1:-1}
    }

    prompt_default_highlight() {
        if [ "$DESKTOP_SESSION" = "gnome" ]; then
            prompt_highlight "${1:-1}"
        else
            unset PROMPT_HIGHLIGHT
        fi
    }

    prompt_default_color() {
        prompt_color "$1"
        prompt_default_highlight
        unset PROMPT_DIR_COLOR
    }

    prompt_dir_color() {
        if [ -n "${1:+1}" ]; then
            PROMPT_DIR_COLOR="$1"
        else
            unset PROMPT_DIR_COLOR
        fi
    }

    # only activate for color terminals and if PS1 unchanged from bash or fedora defaults
    if [ '(' "$PS1" = "[\u@\h \W]\\$ " -o "$PS1" = "\\s-\\v\\\$ " ')' \
             -a '(' "${TERM: -5}" = "color" -o "${TERM}" = "linux" ')' \
             -o -n "${bash_prompt_color_force}" ]; then
        prompt_color "$PROMPT_COLOR"
        prompt_default_highlight "$PROMPT_HIGHLIGHT"
        prompt_dir_color "$PROMPT_DIR_COLOR"
        PROMPT_USERHOST="${PROMPT_USERHOST-${container:+⬢ }\u@\h}"
        PROMPT_SEPARATOR="${PROMPT_SEPARATOR-:}"
        PROMPT_DIRECTORY="${PROMPT_DIRECTORY-\w}"
        prompt_setup_color_ps1
    fi

    # sets default prompt format
    prompt_default_format() {
        PROMPT_USERHOST='\u@\h'
        PROMPT_SEPARATOR=':'
        PROMPT_DIRECTORY='\w'
        PROMPT_START=''
        PROMPT_END=''
    }

    # sets default prompt color and format
    prompt_default() {
        prompt_default_color "$1"
        prompt_default_format
    }

    # sets color to OS ANSI_COLOR
    # $1 is appended to the (foreground) color
    prompt_os_color() {
        if [ -z "$ANSI_COLOR" ]; then
            eval local $(grep ANSI_COLOR /etc/os-release)
        fi
            PROMPT_COLOR="$ANSI_COLOR${1:+;$1}"
    }

    prompt_container() {
        if [ -n "$container" ]; then
            eval local $(grep "\(^ID=\|VERSION_ID\|VARIANT_ID\)" /etc/os-release)
            PROMPT_USERHOST="⬢ $ID-$VARIANT_ID$VERSION_ID"
        else
            if [ "$HOSTNAME" = "fedora" -a "$1" = "$USER" ]; then
                unset PROMPT_USERHOST
            fi
        fi
        }

    # unsets colors
    prompt_no_color() {
        unset PROMPT_COLOR
        unset PROMPT_DIR_COLOR
    }

    # unsets highlighting
    prompt_no_highlight() {
        unset PROMPT_HIGHLIGHT
    }

    # unsets color and highlighting
    prompt_plain() {
        prompt_no_color
        prompt_no_highlight
    }

    # sets traditional Red Hat prompt style format
    prompt_traditional_format() {
        PROMPT_USERHOST='\u@\h'
        PROMPT_SEPARATOR=' '
        PROMPT_DIRECTORY='\W'
        PROMPT_START='['
        PROMPT_END=']'
    }

    # sets traditional Red Hat prompt style without color
    prompt_traditional() {
        prompt_plain
        prompt_traditional_format
    }

    # revert to traditional Red Hat prompt
    prompt_reset_traditional_ps1() {
        PS1="[\u@\h \W]\\$ "
    }

fi
