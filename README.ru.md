# ALT Atomic Image

Базовый образ **ALT Linux** в виде OCI-образа, совместимый с **bootc**.

Этот образ был специально разработан в минималистичном стиле, что делает его подходящим для создания атомарных дистрибутивов, подобных Fedora Silverblue, Vanilla OS и другим.

Представлены образы `core` и `core-minimal`. `core` подходит для создания дистрибутива для конечного пользователя. "core-minimal" больше подходит для конкретных задач, у него даже нет linux-firmware.

Образы не включают графическую среду (DE) или некоторые дополнительные утилиты, но содержат ядро и полезные инструменты для работы с контейнерами, такие как **Podman**.

Вы можете просмотреть полный список пакетов в файле [./src/minimal/resources/packages.yml](./src/minimal/resources/packages.yml) для версии "core-minimal" или [./src/default/resources/packages.yml](./src/default/resources/packages.yml) для `core`

Известные проекты, основанные на этом изображении:

- https://altlinux.space/alt-atomic/onyx
- https://altlinux.space/alt-atomic/kyanite
- https://altlinux.space/vadimpolozowvrn/atomic-cobalt-minimal-kde

### Images

Основные образы:

`core:latest`
`core:<дата>`
`core:<git-коммит>`
`core-minimal:latest`
`core-minimal:<дата>`
`core-minimal:<git-коммит>`

Они собираются при каждом пуше в `main` и ежедневно.

Pull request'ы из этого репозитория публикуются для тестирования как:

`core/pr:<номер PR>`
`core-minimal/pr:<номер PR>`

Совместимые имена для существующих потребителей:

`core/stable:latest`
`core/stable:<дата>`
`core/stable:<git-коммит>`
`core-minimal/stable:latest`
`core-minimal/stable:<дата>`
`core-minimal/stable:<git-коммит>`

Имена с `/stable` указывают на те же образы, что и основные имена.

В хранилище OCI хранится до 50 версий каждого изображения. Срок действия версий, за исключением последней, составляет до 30 дней.

# Сопровождающие

- Владимир Романов <rirusha@altlinux.org>
- Дмитрий Удалов <udalov@altlinux.org>
