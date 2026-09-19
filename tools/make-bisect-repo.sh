#!/usr/bin/env bash
# Створює навчальний репозиторій для вправи з git bisect (ЛР № 3).
#
#   bash tools/make-bisect-repo.sh [КАТАЛОГ] [КІЛЬКІСТЬ_КОМІТІВ]
#
# За замовчуванням: ~/bisect-lab, 30 комітів. Один із комітів ламає програму;
# який саме — обирається випадково, тож у кожного студента відповідь своя.
set -euo pipefail

DIR="${1:-$HOME/bisect-lab}"
N="${2:-30}"

if [ -e "$DIR" ]; then
    echo "Каталог $DIR уже існує. Видаліть його або вкажіть інший:" >&2
    echo "    bash $0 ~/bisect-lab-2" >&2
    exit 1
fi

if [ "$N" -lt 5 ]; then
    echo "Потрібно щонайменше 5 комітів." >&2
    exit 1
fi

# Зламаний коміт — десь у середній третині історії.
BREAK_AT=$(( N / 3 + RANDOM % (N / 3) + 1 ))

mkdir -p "$DIR"
cd "$DIR"
git init -q -b main
git config user.name  "Course Bot"
git config user.email "bot@example.invalid"

cat > test.sh <<'EOF'
#!/usr/bin/env bash
# Повертає 0, якщо sum.c працює правильно, і 1, якщо ні.
# Саме код завершення читає `git bisect run`.
set -u
cc -Wall -o sum sum.c 2>/dev/null || exit 125   # 125 = "цей коміт неможливо перевірити"
result=$(./sum 1 2 3 4 5)
[ "$result" = "15" ]
EOF
chmod +x test.sh

write_sum() {
    # $1 — 1, якщо версія зламана
    local broken="$1" cond
    if [ "$broken" -eq 1 ]; then
        cond='i <= argc'      # вихід за межу argv — на один елемент далі, ніж можна
    else
        cond='i < argc'
    fi
    cat > sum.c <<EOF
#include <stdio.h>
#include <stdlib.h>

/* Підсумовує числа, передані аргументами командного рядка. */
int main(int argc, char *argv[]) {
    long total = 0;
    for (int i = 1; $cond; i++) {
        total += atol(argv[i]);
    }
    printf("%ld\n", total);
    return 0;
}
EOF
}

MESSAGES=(
    "довідка у README"
    "уточнено коментар до циклу"
    "перейменовано змінну лічильника"
    "додано .gitignore"
    "прибрано зайвий пробіл"
    "оновлено опис у README"
    "форматування за стилем проєкту"
    "додано приклад використання"
    "виправлено друкарську помилку"
    "уточнено текст помилки"
)

write_sum 0
echo "# Навчальний репозиторій для вправи з git bisect" > README.md
printf 'sum\n' > .gitignore
git add .
git commit -q -m "початкова версія: підсумовування аргументів"

for i in $(seq 2 "$N"); do
    if [ "$i" -eq "$BREAK_AT" ]; then
        write_sum 1
        git add sum.c
        git commit -q -m "оптимізовано цикл підсумовування"
    else
        echo "# зміна $i" >> README.md
        git add README.md
        git commit -q -m "${MESSAGES[$(( (i - 1) % ${#MESSAGES[@]} ))]} ($i)"
    fi
done

echo "Готово: $DIR"
echo "Комітів в історії: $(git rev-list --count HEAD)"
echo
echo "Перевірте, що поточний стан зламано:"
echo "    cd $DIR && ./test.sh; echo \$?"
