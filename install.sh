#!/bin/bash

# URL для скачивания Giga IDE
DOWNLOAD_URL="https://gigaide.ru/downloadlast/gigaideCE-242.21829.142.2.tar.gz"
FILENAME="gigaideCE.tar.gz"
DIR_NAME="gigaide-CE-242.21829.142.2"
INSTALL_PATH="/opt/$DIR_NAME"

# Проверка наличия необходимых утилит
if ! command -v curl &> /dev/null; then
    echo "Ошибка: curl не установлен. Установите его с помощью: sudo apt install curl"
    exit 1
fi

if ! command -v tar &> /dev/null; then
    echo "Ошибка: tar не установлен. Установите его с помощью: sudo apt install tar"
    exit 1
fi

# Скачивание архива
echo "Скачивание Giga IDE..."
curl -L -o "$FILENAME" "$DOWNLOAD_URL"

# Проверка успешности скачивания
if [ $? -ne 0 ]; then
    echo "Ошибка при скачивании Giga IDE"
    rm -f "$FILENAME"
    exit 1
fi

# Распаковка архива
echo "Распаковка архива..."
tar -xzf "$FILENAME"

# Проверка успешности распаковки
if [ $? -ne 0 ]; then
    echo "Ошибка при распаковке архива"
    rm -f "$FILENAME"
    exit 1
fi

# Удаление архива
rm -f "$FILENAME"

# Перемещение в /opt/ (требуются права суперпользователя)
echo "Установка в $INSTALL_PATH..."
sudo mkdir -p /opt
sudo mv "$DIR_NAME" "$INSTALL_PATH"

# Проверка существования исполняемого файла
if [ ! -f "$INSTALL_PATH/bin/idea" ]; then
    echo "Предупреждение: файл $INSTALL_PATH/bin/idea не существует."
    echo "Попробуем использовать idea.sh вместо idea."
    if [ ! -f "$INSTALL_PATH/bin/idea.sh" ]; then
        echo "Ошибка: ни idea, ни idea.sh не найдены в $INSTALL_PATH/bin/"
        exit 1
    fi
    EXEC_FILE="idea.sh"
else
    EXEC_FILE="idea"
fi

# Создание .desktop файла
DESKTOP_FILE="$HOME/.local/share/applications/gigaide.desktop"
echo "Создание файла запуска..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=GigaIDE
Comment=Giga IDE
Exec="$INSTALL_PATH/bin/$EXEC_FILE" %f
Icon=$INSTALL_PATH/bin/idea.png
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea
EOF

# Даем права на выполнение .desktop файла
chmod +x "$DESKTOP_FILE"

# Обновляем кэш приложений
update-desktop-database "$HOME/.local/share/applications" &> /dev/null

echo -e "\033[1;32mGiga IDE успешно установлена!\033[0m"
echo "Вы можете найти её в меню приложений в разделе Разработка (Development)"
echo ""
echo "Если возникнут проблемы с запуском, проверьте файл $DESKTOP_FILE"
echo "и убедитесь, что путь к исполняемому файлу корректен."