# Ruby Brewer
### A Ruby API for adaptiman/adaptibrew

# Disclaimer
This is just an API to make adaptibrew more user friendly. It will provide a clean shell and easy to understand methods for all the actions you need to control your brew rig. This will require an actual brew rig and all the equipment listed in [adaptiman/adaptibrew](https://github.com/adaptiman/adaptibrew). If you are looking to build an automated brew rig, **this is not the place to start**. Head over to [adaptiman/adaptibrew](https://github.com/adaptiman/adaptibrew), or get in contact with [adaptiman](https://github.com/adaptiman).

# Running
To initialize, run
```shell
ruby brewer
```
from inside the root directory. This will open up a Ripl shell.

# Testing
Run
```shell
ruby ts_all.rb
```
**from inside the tests directory**. Running them outside of that directory will screw things up, since it involves cloning git repos, and paths and such. 
