# Лабораторна робота № 3

**C проти Rust: одна утиліта двома мовами, Git і код-рев'ю**

Повний текст роботи — у Google Classroom. Тут лише те, що потрібно для здачі.

## Що здається

```
lab03/submissions/ГРУПА_Прізвище/
├── c/
│   ├── minigrep.c
│   └── Makefile
├── rust/
│   ├── Cargo.toml
│   └── src/main.rs
└── REPORT.md
```

## Вимоги до утиліти

```
minigrep ШАБЛОН ФАЙЛ
```

- виводить рядки файлу, що містять `ШАБЛОН`, у форматі `номер:рядок`;
- код повернення `0` — знайдено, `1` — не знайдено, `2` — помилка аргументів
  або файлу (повідомлення в `stderr`).

Обидві реалізації мають поводитися однаково:

```bash
./c/minigrep malloc c/minigrep.c > /tmp/out_c.txt;              echo "C: $?"
./rust/target/debug/minigrep malloc c/minigrep.c > /tmp/out_rs.txt; echo "Rust: $?"
diff /tmp/out_c.txt /tmp/out_rs.txt && echo "вивід збігається"
```

## Вправа з git bisect

```bash
bash tools/make-bisect-repo.sh
cd ~/bisect-lab
git bisect start HEAD $(git rev-list --max-parents=0 HEAD)
git bisect run ./test.sh
git bisect reset
```

Скрипт щоразу ламає інший коміт, тож відповідь у кожного своя.

## Що має бути в REPORT.md

Середовище · таблиця вимірювань (рядки коду, час збірки, розмір бінарників) ·
відповіді на вісім питань для звіту · відповіді на контрольні питання · висновки.
