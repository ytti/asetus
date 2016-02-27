# Asetus
Configuration library for ruby with YAML/JSON/TOML backends with unified object
access

## Install
```
 % gem install asetus
```

## Use
### Simple
```
require 'asetus'
cfg  = Asetus.cfg
port = cfg.server.port
user = cfg.auth.user
pw   = cfg.auth.password
```
It tried to detect your software name via caller_locations if no ':name'
argument was given.
It automatically loads /etc/name/config and ~/.config/name/config and merges
them together.

### Advanced
```
require 'asetus'
asetus = Asetus.new name:    'mykewlapp',
                    default: {'poop'=>'xyzzy'},
                    adapter: 'yaml',
                    usrdir:  '/home/app/config/',
                    sysdir:  '/System/config/',
                    load:    false
asetus.default.poop2 = [1, 2, 3, 4]
asetus.default.starship.poopoers = 42
asetus.load :user
if asetus.user.empty?
  asetus.user = asetus.default
  asetus.save :user
end
asetus.load    # load+merges cfg, takes argument :default, :system, :user
asetus.cfg     # merged default + system + user  (merged on load)
asetus.default # default only
asetus.system  # system only
asetus.user    # user only
```

## Reserved methods

* each           - iterate all config keys in current level
* has_key?(arg)  - check if current level has key arg
* [arg]          - fetch arg (useful for non-literal retrieval, instead of using #send)
* key?           - all keys have question mark version reserved, checks if key exists+true (true), exists+false (false), not-exists (nil)
+ all object class methods

## TODO

  * should I add feature to raise on unconfigured/unset?
  * should I always merge to 'cfg' when default/system/config is set?

## License and Copyright

Copyright 2014-2016 Saku Ytti <saku@ytti.fi>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
