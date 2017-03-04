# Ruby Brewer
### A Ruby API for adaptiman/adaptibrew

# Disclaimer
This is just an API to make adaptibrew more user friendly. It will provide a clean shell and easy to understand methods for all the actions you need to control your brew rig. This will require an actual brew rig and all the equipment listed in [adaptiman/adaptibrew](https://github.com/adaptiman/adaptibrew). If you are looking to build an automated brew rig, **this is not the place to start**. Head over to [adaptiman/adaptibrew](https://github.com/adaptiman/adaptibrew), or hit up [adaptiman](https://github.com/adaptiman).

# Running
You'll need Ruby installed of course.

First, you need to install missing gems. To do that, run
```shell
bundle install
```
from inside the root directory. If there are any errors, bundler will probably tell you how to solve them. Otherwise, gg wp.

To initialize, run
```shell
brewer
```
from inside the root directory. This will open up a Ripl shell.

**If that doesn't work**, the `brewer` file might not be executable. Run
```shell
sudo chmod +x brewer
```
to make it executable and try again.

# Testing
Run
```shell
tests/unit
```
from the project root to run all tests. You can also run a specific test case with
```shell
ruby tests/tc_brewer.rb
```
using `tc_brewer.rb` as an example.
A code coverage report will be created in `coverage/`, but only if all tests are run, not specific test cases.
