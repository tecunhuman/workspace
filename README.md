workspace
=========

Development infrastructure and example projects for tecunhuman.

Projects
--------

* `forge` - local Forgejo server and Actions runner.
* `build-containers` - container images for cross-platform Godot builds.
* `project-example` - example project using the build containers.

Getting started
---------------

Clone the workspace and initialize its submodules:

```bash
git clone --recurse-submodules <repository-url>
cd workspace
```

Each project has its own README with setup and usage instructions.

Backups
-------

Copy the example configuration and set the backup destination:

```bash
cp .env.example .env
make backup-check
make backup
```

`make backup-check` performs an `rsync` dry run. `make backup-delete` also removes files from the destination that no
longer exist in the workspace.
