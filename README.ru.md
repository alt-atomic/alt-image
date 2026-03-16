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

`core/nightly:<дата>`
`core/nightly:<git-коммит>`
`core/nightly:latest`

Создается на основе всех изменений в репозитории, с использованием ветки main и на ежедневной основе. Изменения во внешних ветвях загружаются под названием core/nightly-branch:<название ветки> для целей тестирования.

`core/stable:<дата>`
`core/stable:<git-тег>`
`core/stable:<git-релиз>`
`core/stable:<git-коммит>`
`core/stable:latest`

Собиратся образы при пуше тега. Также создается ежедневно с использованием последнего тега и свежей даты.

В хранилище OCI хранится до 50 версий каждого изображения. Срок действия версий, за исключением последней, составляет до 30 дней.

# Сопровождающие

- Владимир Романов <rirusha@altlinux.org>
- Дмитрий Удалов <udalov@altlinux.org>
