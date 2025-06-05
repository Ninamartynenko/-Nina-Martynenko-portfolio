#!/usr/bin/env bash

# -----------------------------------------------
# Скрипт: deploy_to_github.sh
# Призначення: Ініціалізувати Git, закидати код сайту на GitHub
# Перед використанням:
#  1. Замініть GITHUB_USERNAME і REPO_NAME на свої значення.
#  2. Переконайтеся, що на GitHub вже є створене пусте репо https://github.com/GITHUB_USERNAME/REPO_NAME
#  3. Помістіть цей скрипт у корінь проєкту (де лежать index.html, about.html тощо).
#  4. Зробіть скрипт виконуваним: chmod +x deploy_to_github.sh
#  5. Запустіть: ./deploy_to_github.sh
# -----------------------------------------------

# === Налаштування (змініть свої дані) ===
GITHUB_USERNAME="Ninamartynenko"         # Наприклад, nina-martynenko
REPO_NAME="-Nina-Martynenko-portfolio"           # Назва репозиторію на GitHub
BRANCH="main"                      # Гілка, яку будемо пушити (може бути "main" або "master")

# -----------------------------------------------
# Крок 1: Перевірка, чи є поточна папка Git-репо
if [ -d ".git" ]; then
  echo "✔ У цьому каталозі вже існує папка .git, пропускаємо git init."
else
  # Ініціалізуємо новий Git-репозиторій
  git init
  echo "✔ Ініціалізовано новий Git-репозиторій."
fi

# -----------------------------------------------
# Крок 2: Додаємо віддалений origin (якщо його ще не додано)
REMOTE_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
EXISTING_REMOTE=$(git remote 2>/dev/null)

if echo "$EXISTING_REMOTE" | grep -q "origin"; then
  echo "✔ Віддалений 'origin' вже налаштований: $(git remote get-url origin)"
else
  git remote add origin "$REMOTE_URL"
  echo "✔ Додано віддалений репозиторій origin → $REMOTE_URL"
fi

# -----------------------------------------------
# Крок 3: Створюємо .gitignore (якщо потрібно)
# Наприклад, ігноруємо тимчасові файли OS чи IDE:
cat > .gitignore <<EOF
# HTTP caching
*.html~

# Node.js / VSCode / Mac OS / Windows / інші тимчасові
node_modules/
.vscode/
.DS_Store
Thumbs.db
*.log
EOF

echo "✔ Створено базовий .gitignore (підлаштуйте за потребою)."

# -----------------------------------------------
# Крок 4: Додаємо всі файли та перший коміт
git add .
git commit -m "Initial commit: add portfolio files"

echo "✔ Зроблено перший коміт із повідомленням 'Initial commit: add portfolio files'."

# -----------------------------------------------
# Крок 5: Перейменовуємо гілку (якщо потрібно) і пушимо у віддалений репо
#        Якщо у вас уже є гілка main, і ви хочете лишити master — змініть BRANCH на master.
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
  git branch -M "$BRANCH"
  echo "✔ Перейменовано гілку '$CURRENT_BRANCH' → '$BRANCH'."
fi

git push -u origin "$BRANCH"

if [ $? -eq 0 ]; then
  echo "✔ Успішно запушено на GitHub у гілку '$BRANCH'."
else
  echo "✖ Помилка під час пушу. Перевірте правильність URL та ваші права доступу."
  exit 1
fi

# -----------------------------------------------
# Крок 6: Увімкнення GitHub Pages (через API)
# Для автоматичного вмикання GitHub Pages можна скористатися GitHub CLI (gh) або GitHub API.
# Нижче приклад із використанням GitHub CLI (якщо встановлено gh).
# Якщо ви не маєте GitHub CLI, цю частину можна пропустити та включити Pages вручну в налаштуваннях репозиторію.

if command -v gh >/dev/null 2>&1; then
  echo "ℹ GitHub CLI (gh) знайдено – налаштовуємо GitHub Pages автоматично..."
  # Створюємо запис GitHub Pages (гілка: BRANCH, папка: /root)
  gh repo edit "${GITHUB_USERNAME}/${REPO_NAME}" --enable-pages
  gh api     -X PUT     -H "Accept: application/vnd.github.v3+json"     /repos/"${GITHUB_USERNAME}"/"${REPO_NAME}"/pages     -f source="{'branch':'$BRANCH','path':'/'}"
  if [ $? -eq 0 ]; then
    echo "✔ GitHub Pages увімкнено."
  else
    echo "✖ Не вдалося автоматично увімкнути GitHub Pages. Налаштуйте вручну у Settings → Pages."
  fi
else
  echo "ℹ GitHub CLI (gh) НЕ знайдено – трішки підкажемо, як увімкнути Pages вручну:"
  echo "  1) Зайдіть у репозиторій на GitHub."
  echo "  2) Перейдіть у Settings → Pages."
  echo "  3) В розділі 'Source' виберіть гілку: $BRANCH, папку: '/' і натисніть 'Save'."
  echo "  4) Через хвилину ваш сайт буде доступний за URL: https://${GITHUB_USERNAME}.github.io/${REPO_NAME}/"
fi

# -----------------------------------------------
echo "=============================="
echo "🎉 Деплой завершено!"
echo "Перейдіть за посиланням: https://${GITHUB_USERNAME}.github.io/${REPO_NAME}/"
echo "=============================="
