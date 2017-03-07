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
from inside the root directory. This will open up a Ripl shell. It looks like this:
```shell
>>
```

**If that doesn't work**, the `brewer` file might not be executable. Run
```shell
sudo chmod +x brewer
```
to make it executable and try again.

# Testing & Rake
Run
```shell
rake test
```
to run all tests. You can run a specific test case with
```shell
rake test['adaptibrew']
```
This will run `tests/tc_adaptibrew.rb`. You can of course change `adaptibrew` to another `tc_*.rb` in order to run specific test cases.

A code coverage report will be created in `coverage/` upon testing. Checkout `coverage/index.html` to view the report. You can also run
```shell
rake coverage
```
to see the coverage report.

## Other rake commands

Delete, clone, or refresh (delete and re-clone), with
```shell
rake adaptibrew['clear']
rake adaptibrew['clone']
rake adaptibrew['refresh']
```
