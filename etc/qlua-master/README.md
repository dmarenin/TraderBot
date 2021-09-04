Qlua (Quik LUA RPC Python)
==========================

[![pipeline status](https://gitlab.com/abrosimov.a.a/qlua/badges/master/pipeline.svg)](https://gitlab.com/abrosimov.a.a/qlua/-/commits/master)
<!---[![coverage report](https://gitlab.com/abrosimov.a.a/qlua/badges/master/coverage.svg)](https://gitlab.com/abrosimov.a.a/qlua/-/commits/master)-->

[Python](https://ru.wikipedia.org/wiki/Python) API
для торгового терминала [Quik](https://arqatech.com/ru/products/quik/).
Представляет собой клиентскую часть для [Quik LUA RPC](https://github.com/Enfernuz/quik-lua-rpc).

Принцип работы
--------------

* Терминал [Quik](https://arqatech.com/ru/products/quik/) предоставляет API для языка программирования LUA.
* Проект [Quik LUA RPC](https://github.com/Enfernuz/quik-lua-rpc) позволяет обращаться к Quik LUA API, через сетевое подключение.
[ZeroMQ](https://zeromq.org/) обеспечивает передачу данных по сети и аутентификацию.
[Protocol Buffers](https://developers.google.com/protocol-buffers) позволяет программам, написанным на разных языках программирования, быстро обмениваться данными.
* Проект Qlua, описание которого вы читаете, позволяет взаимодействовать с Quik LUA RPC из языка программирования Python.
* Таким образом ваш код на Python взаимодействует с API Quik.

Установка
---------

1. Установите пакет `qlua`:
   ```sh
   pip install qlua
   ```
2. Можно пользоваться API.
   * Примеры использования [qlua/examples](https://gitlab.com/abrosimov.a.a/qlua/-/tree/master/qlua/examples)
   * Интерфейс командной строки можно вызвать используя:
     ```sh
     python -m qlua -h
     ```

**Внимание!** Для работы CLI (интерфейса командной строки) требуется:

  * `python >= 3.7.0`
  * Для `python < 3.8.0` необходимо установить [MyPy](https://github.com/python/mypy):
    ```sh
    pip install mypy
    ```

Документация
------------

* Более подробная документация находится в [Wiki](https://gitlab.com/abrosimov.a.a/qlua/-/wikis/home).
