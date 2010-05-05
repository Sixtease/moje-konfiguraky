ve(){ du -h "$1" | tail -n 1; }

jd(){
	if [ -d "$1" ]; then
		cd "$1"
	else
		mkdir -p "$1"
		cd "$1"
	fi
}

governor() {
    gov="$1"

    # obnovit minimalni frekvenci
    cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

    if [ -z "$gov" ]; then
        echo -n 'cpu0: '
        cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        echo -n 'cpu1: '
        cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
        return 0
    fi

    # zkontrolovat validitu governora
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors | perl -e '
        $govs = <STDIN>;
        @govs = split /\s+/, $govs;
        if (grep {$_ eq q('"$1"')} @govs) {
            exit(0);
        }
        $" = q{", "};
        print STDERR qq{CHYBA: spatny governor (chcu jeden z "@govs")\n};
        exit(1);
    ' || return 1

    # nastavit
    echo "$1" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo "$1" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor

    # zkontrolovat uspech
    if [ "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)" = "$1" ]
    then echo "Governor 0 OK"
    else echo -n "CHYBA: Governor 0 je: "; cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    fi

    if [ "$(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor)" = "$1" ]
    then echo "Governor 1 OK"
    else echo -n "CHYBA: Governor 1 je: "; cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
    fi
}

# do promenne N uloz retezec S zmeneny prikazem sed sP1;sP2;...
s() {
    if (($# == 0)); then echo 'USAGE: s <output_variable_name> <string> /<pattern>/<replacement>/ [/<pattern>/<replacement>/ ...]'; return 1; fi
    prom=$1
    shift
    str=$1
    shift
    sedcom=
    while (($# > 0)); do
        if [ -z "$sedcom" ]; then
            sedcom="s$1"
        else
            sedcom="${sedcom};s$1"
        fi
        shift
    done
    eval "$prom=\$(echo \"$str\" | sed '$sedcom')"
}

mtisofs() {
    mount -o loop=/dev/loop/0 "$1" "${2:-/mnt/isofs}"
}

pocty() {
    sort | uniq -c | sort -nrk 1
}

check() {
    perl -M$1 -le '($p="'"$1"'")=~s{::}{/}g; print $'"$1"'::VERSION, " ", $INC{"$p.pm"}'
}

natrunk() { (
    set -x
    git checkout -b 'trunk' remotes/svn/trunk # switchnout do trunku
    git branch -D master # smazat master
    git branch -M trunk master # přejmenovat trunk na master
) }

#export LC_ALL=cs_CZ.UTF-8
export PATH=${PATH}${PATH:+:}.
export LESSCHARSET="utf-8"
export HISTFILESIZE=50000
export HISTSIZE=50000
export HISTCONTROL='ignoreboth:erasedups'
export EDITOR=/usr/bin/vim
export SVN_EDITOR=/usr/bin/vim
export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \W \$\[\033[00m\] '
export TEMPDIR=/home/sixtease/temp

alias ll="ls -la"
alias lh="ls -lah"
alias rr="rm -R"
alias cp="cp -vi"
alias mv="mv -vi"
alias vi=vim
alias vir="vim -R"
alias ..="cd .."
alias ...="cd ../.."
alias radio1="mplayer http://netshow.play.cz:8000/radio1.mp3"
alias ct24="mplayer mms://ct24stream.visual.cz/CT24-Zvuk"
alias cpan='sudo env PERL5LIB="$PERL5LIB" cpan'
