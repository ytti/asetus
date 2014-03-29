# Asetus
Configuration library for ruby with YAML/JSON backends with unified object
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

## TODO

  * should I add feature to raise on unconfigured/unset?
  * should I always merge to 'cfg' when default/system/config is set?
