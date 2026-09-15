# ~/.bash_functions - Custom bash functions

envLoad() {
    local env_file="${1:-.env}"
    local line key value line_number=0

    if [[ ! -f "$env_file" ]]; then
        printf 'envLoad: environment file not found: %s\n' "$env_file" >&2
        return 1
    fi

    while IFS= read -r line || [ -n "$line" ]; do
        line_number=$((line_number + 1))
        line=${line%$'\r'}
        [[ -z "${line//[[:space:]]/}" || "$line" == \#* || "$line" == [[:space:]]#* ]] && continue
        [[ "$line" == export[[:space:]]* ]] && line=${line#export }

        if [[ "$line" != *=* ]]; then
            printf 'envLoad: invalid entry at %s:%s (expected KEY=VALUE)\n' "$env_file" "$line_number" >&2
            return 1
        fi

        key=${line%%=*}
        value=${line#*=}
        if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
            printf 'envLoad: invalid variable name at %s:%s\n' "$env_file" "$line_number" >&2
            return 1
        fi

        if [[ ${#value} -ge 2 && "$value" == \"*\" ]]; then
            value=${value:1:${#value}-2}
        elif [[ ${#value} -ge 2 && "$value" == \'*\' ]]; then
            value=${value:1:${#value}-2}
        fi

        export "$key=$value"
    done < "$env_file"
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
