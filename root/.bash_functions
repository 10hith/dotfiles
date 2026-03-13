# ~/.bash_functions - Custom bash functions

envLoad() {
    export $(cat .env | xargs)
}

envAct() {
    if [ -d "venv" ]; then
        source venv/bin/activate
    elif [ -d ".venv" ]; then
        source .venv/bin/activate
    else
        echo "No virtual env found"
    fi
}

killJupyter() {
    ps -ef | grep jupyter | grep -v grep | awk '{print $2}' | xargs -r kill -9
}
