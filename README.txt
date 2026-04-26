# orca

Getting Started

brew install xcodegen
xcodegen generate
make run

If signed simulator builds need an explicit team on your machine, run `make run DEVELOPMENT_TEAM=<team id>`.


`project.yml` is the source of truth for targets, package dependencies, schemes, and build settings. Regenerate the Xcode project whenever it changes.
