# ALT Atomic Image

The base image of **ALT Linux** in the form of an OCI image, compatible with **bootc**.

This image has been specifically designed to be minimalistic, making it suitable for building atomic distributions similar to Fedora Silverblue, Vanilla OS, and others.

There is a `core` image and a `core-minimal;`. `core` is suitable for creating a distribution package for the end user. `core-minimal` is more suitable for specific tasks, it doesn't even have linux firmware.

The images does not include a graphical environment (DE) or some additional utilities, but it does contain a kernel and useful container tools such as **Podman**.

You can view the complete list of packages in the file [./src/minimal/resources/packages.yml](./src/minimal/resources/packages.yml) for `core-minimal` version or [./src/default/resources/packages.yml](./src/default/resources/packages.yml) for `core`

Known projects based on this image:

- https://altlinux.space/alt-atomic/onyx
- https://altlinux.space/alt-atomic/kyanite
- https://altlinux.space/vadimpolozowvrn/atomic-cobalt-minimal-kde

### Images

`core/nightly:<date>`
`core/nightly:<git-commit>`
`core/nightly:latest`

Built upon every change in the repository, using the main branch, and on a daily basis. Changes in external branches are uploaded under the name core/nightly-branch:<branch-name> for testing purposes.

`core/stable:<date>`
`core/stable:<git-tag>`
`core/stable:<git-release>`
`core/stable:<git-commit>`
`core/stable:latest`

Built upon tag push. Also built daily using the latest tag and fresh date.

The OCI storage retains up to 50 versions of each image. Versions, except for latest, live for up to 30 days.

# Maintainers

- Vladimir Romanov <rirusha@altlinux.org>
- Dmitry Udalov <udalov@altlinux.org>
