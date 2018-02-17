plog () {
    pushd () {
        command pushd "$@" > /dev/null
    }

    popd () {
        command popd "$@" > /dev/null
    }

    PLOGDIR=~/.plog/
    PLOGGDIR=${PLOGDIR}.git/
    
    if [ "$1" == "init" ]
    then
        [ -d $PLOGDIR ] || mkdir $PLOGDIR
        pushd $PLOGDIR
        git init --quiet
        popd
    fi
    
    if [ ! -d "$PLOGDIR" ]
    then
        echo "plog not initialized"
        return 1
    fi

    if [ -z "$1" ]
    then
        pushd $PLOGDIR
        git log --no-notes --date=local --format="%C(cyan)%ad, %ar: %C(white)%s"  --no-merges
        popd
    fi
    
    if [ "$1" == "sync" ]
    then
        pushd $PLOGDIR
        git pull
        git push
        popd
    fi
    
    if [ "$1" == "add" ]
    then
        pushd $PLOGDIR
        git commit --quiet --allow-empty -m "${*:2}"
        popd
    fi
}
