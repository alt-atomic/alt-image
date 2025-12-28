# ALT Atomic Image

The base image of **ALT Linux** in the form of an OCI image, compatible with **bootc**.

This image has been specifically designed to be minimalistic, making it suitable for building atomic distributions similar to Fedora Silverblue, Vanilla OS, and others.

The image does not include a graphical environment (DE) or some additional utilities, but it does contain a kernel and useful container tools such as:

- **Podman**
- **Docker**

You can view the complete list of packages in the file [./src/packages/01-package-list.sh](./src/packages/01-package-list.sh)

Known projects based on this image:

- https://altlinux.space/alt-atomic/onyx

### Images

`core/nightly:<date>`
`core/nightly:latest`

Built upon every change in the repository, using the main branch, and on a daily basis. Changes in external branches are uploaded under the name core/nightly-branch:<branch-name> for testing purposes.

`core/stable:<date>`
`core/stable:<git-tag>`
`core/stable:latest`

Built upon tag push. Also built daily using the latest tag and fresh date.

The OCI storage retains up to 50 versions of each image. Versions, except for latest, live for up to 30 days.

# Owners

- Vladimir Romanov <rirusha@altlinux.org>
- Dmitry Udalov <udalov@altlinux.org>
