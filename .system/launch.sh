version="2.1"

# Remover arquivos antigos
if [ -f .system/a.out ]; then
    sleep 0.1
    rm ./.system/a.out
    exit 0
fi

if [ -f .system/.devmake.err ]; then
    rm .system/.devmake.err
fi

if [ -f .system/readline_ok ]; then
    rm .system/readline_ok
fi

export LOGNAMELOG42EXAM="$LOGNAME"

MANGENTA="\033[35m"
BOLD="\033[1m"
CLEAR_LINE="\033[2K"
LINE_UP="\033[1A"
RED="\033[31m"
WHITE="\033[37m"
GRAY="\033[90m"
BLUE="\033[34m"
GREEN="\033[32m"
RESET="\033[0m"
spin[0]="⠁"
spin[1]="⠃"
spin[2]="⠇"
spin[3]="⠧"
spin[4]="⠷"
spin[5]="⠿"
spin[6]="⠷"
spin[7]="⠧"
spin[8]="⠇"
spin[9]="⠃"

if [ "$1" != "grade" ]; then
    if [ "$1" != "gradejustinstall" ]; then
        clear
    fi
fi

ping -c 1 google.com >/dev/null 2>&1 &
PID=$!

while [ -d /proc/$PID ]; do
    for i in "${spin[@]}"; do
        echo -ne "$LINE_UP$WHITE$i$RESET Checking server availability\n"
        for i in {1..32}; do
            printf "\b"
        done
        sleep 0.1
    done
done

if [ "$1" != "gradejustinstall" ]; then
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        printf "$LINE_UP$CLEAR_LINE$RED"
        echo -ne "✗$RESET Checking server availability$WHITE$BOLD\n"
        echo -ne "  ➫ Local launch\n\n"
    else
        git pull >/dev/null 2>&1 &
        printf "$LINE_UP$CLEAR_LINE$RED"
        printf "$GREEN$BOLD"
        echo -ne "✔$RESET You have the last version$GREEN$BOLD v$version\n\n"
    fi
fi

# Verificar biblioteca readline
g++ .system/checkreadline.cpp -o .system/readline_ok 2>.system/.devmake.err &

if [ ! -f .system/readline_ok ]; then
    for i in "${spin[@]}"; do
        echo -ne "$LINE_UP$WHITE$i$WHITE$BOLD Checking readline library\n"
        for i in {1..29}; do
            printf "\b"
        done
        sleep 0.1
    done
fi

printf "$LINE_UP$CLEAR_LINE$GREEN$BOLD"
echo -ne "✔$RESET Checking readline library$WHITE$BOLD\n\n"

if [ ! -f .system/readline_ok ]; then
    printf "$LINE_UP$CLEAR_LINE$RED"
    printf "$LINE_UP$CLEAR_LINE$RED"
    echo -ne "✗$RESET Readline is not installed$WHITE$BOLD\n"
    echo -ne "$RED$BOLD"
    echo -ne "Readline library not installed $WHITE$BOLD\n"
    echo -e " ➫ Please ensure it is installed in the Dockerfile.\n"
    exit 1
fi

rm -rf .system/readline_ok

# Compilar o programa principal
g++ .system/exercise.cpp .system/main.cpp .system/menu.cpp .system/exam.cpp .system/utils.cpp .system/grade_request.cpp .system/data_persistence.cpp -lreadline -o .system/a.out >.system/.devmake.err 2>.system/.devmake.err &
PID=$!

# Enquanto não houver o arquivo a.out, aguarde
while [ ! -f .system/a.out ]; do
    for i in "${spin[@]}"; do
        echo -ne "$LINE_UP$WHITE$i$WHITE$BOLD Compilation of$BOLD$MANGENTA 42_EXAM $RESET\n"
        if [ -f .system/.devmake.err ]; then
            result=$(awk '{t+=length($0)}END{print t}' .system/.devmake.err)
            if [ "$result" != "" ]; then
                sending=$(cat .system/.devmake.err)
                printf "$LINE_UP$CLEAR_LINE$RED"
                echo -ne "✗$RESET Compilation of$BOLD$MANGENTA 42_EXAM $RESET\n"
                printf "$RED$BOLD"
                printf "Oops !$WHITE$BOLD Something went wrong during the compilation...\n"
                echo "Please make a report on Github repo, make sure to include this :"
                echo ""
                printf "      - Your OS:$RESET$GRAY $(uname -a)$WHITE$BOLD\n"
                printf "      - The error message:$RESET$GRAY\n"
                cat .system/.devmake.err
                printf "$WHITE$BOLD"
                echo ""
                echo "Thanks for your contribution !"
                exit 0
            fi
        fi
        sleep 0.1
        for i in {1..30}; do
            printf "\b"
        done
    done
done

check_package() {
    if ! command -v "$1" &>/dev/null; then
        return 1
    fi
}

# Verificar se os compiladores estão instalados
for compiler in clang clang++ gcc g++; do
    if ! check_package "$compiler"; then
        echo "O compilador $compiler não está instalado no sistema."
        echo "Por favor, instale-o para continuar."
        exit 1
    fi
done

printf "$LINE_UP$CLEAR_LINE$GREEN$BOLD"
echo -ne "✔$RESET Compilation of$BOLD$MANGENTA 42_EXAM $RESET\n"

chmod +x .system/a.out

# Verificar variável USER
if [ -z "$USER" ]; then
    if [ -f .system/.env ]; then
        export USER=$(cat .system/.env)
        echo "Variable USER set to $USER ✅"
        ./.system/a.out
        exit 0
    fi
    echo "USER is not set, you must enter your 42 login to use this program "
    echo -ne "Enter your 42 login : "
    read -r user_login
    export USER="$user_login"
    echo "USER=$user_login" >.system/.env
    echo "Variable USER set to $USER ✅"
fi

./.system/a.out