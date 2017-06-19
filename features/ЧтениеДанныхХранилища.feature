# language: ru

Функционал: Чтение данных по истории версий и авторов хранилища конфигурации
    Как разработчик
    Я хочу иметь возможность получать историю версий хранилища из использования сторонних библиотек
    Чтобы мочь автоматизировать больше рутинных действий на OneScript

Контекст:
    Допустим Я создаю новый объект МенеджерХранилищаКонфигурации
    И Я создаю временный каталог и сохраняю его в контекст
    И Я копирую тестовое хранилище во временный каталог
    И Я сохраняю значение временного каталога в переменной "КаталогХранилищаКонфигурации"

Сценарий: Чтение информации из хранилища без подключения
    Допустим Я устанавливаю каталог хранилища во временный каталог
    И Я устанавливаю параметры авторитизации пользователя "Администратор" и пароль ""
    Когда Я читаю данные из хранилища
    Тогда Я получаю таблицу версий хранилища
    И Таблица версий содержит "5" записи
    И Я получаю массив авторов хранилища
    И Количество в массиве авторов равно "1"