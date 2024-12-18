# To contribute

**If you are working on an [existing issue](https://github.com/deniszholob/template-godot-project/issues), please claim it with your comment, so there is no duplicate work.**

## What you will need before you begin:
1. Ensure that [Godot](https://godotengine.org/) is installed
2. Clone the repository using git cli or ui like github desktop/sourcetree/gitkraken etc...
3. Open Godot and `Import` the `project.godot`.
   * Optionally open the cloned folder using VSCode and **install recommended extensions**
4. Click the play button in the top right in the godot editor to run the game.


## Hidden Files in VSCode

Some files are hidden in vscode by default, see the `files.exclude` option in the [settings file](.vscode/settings.json)

There is a [recommended extension](.vscode/extensions.json) `adrianwilczynski.toggle-hidden` that allows to easily toggle hidden files on and off

## Where to find stuff/Project Structure
- Most relevant project folders are `assets`, `components`, `global`, and `scenes`.
- The main scene is in [./scenes/levels/main.tscn](./scenes/levels/main.tscn)
- The [global](./global/) folder contains singleton services that are registered to autoload.
- The [components](./components/) folder contains reusable scripts that can be added to various nodes

# Build + Publish to Itch.io
Manually trigger [Github Deploy Action](https://github.com/deniszholob/template-godot-project/actions/workflows/deploy.yml) when you want to deploy a new version to itch.io.
