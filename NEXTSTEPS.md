# switch command

should be some shortcuts

switch cronin

should look for shops in an app

switch with no arguments
you get a list:

test shops:
1. cronin

apps (development):
1. metafieldseditor
2. shipping

apps (heroku):
1. metafieldseditor
2. shipping

_pry_.switch
  Switch is a class, and every instance of Pry has an instance of Switch. This way we can
  access _pry_.switch. In the global scope there will be an object called 'switch' that will
  be an alias to _pry_.switch so that we can call its public methods. There will also be a 
  command 'switch' that will be a wrapper for the _pry_.switch methods for displaying and
  handling a menu.

  So we can do

  `[1] pry(main)> switch`

  to present a menu of options and then

  `[1] pry(main)> switch 3`

  to choose one of them. This command just refers to methods on Pry.Switch in its process definition

  Or we can use tab completion to present the menu by invoking switch as a global object.

````
  [1] pry(main)> switch.m[TAB]
  switch.metafieldseditor switch.morfars-metafields
  [2] pry(main)> switch.mo[TAB]rfars-metafields
````

  to accomplish the same.

   - When you use switch by itself, with no args, then _pry_.switch gets reset to the first menu
   - each time you make a choice, this advances _pry_.switch to the next menu

  So in a deep menu we might see:

````
  [1] pry(main)> switch
  current shop: none

  Heroku Apps
  1. right app
  2. wrong app
  [1] pry(main)> switch 2
  current shop: none

  Wrong App
  1. not ok
  2. something
  [1] pry(main)> switch
  current shop: none

  Heroku Apps
  1. right app
  2. wrong app
  [1] pry(main)> switch 1
  current shop: none

  Wrong App
  1. another thing
  2. the thing you wanted
  [1] pry(main)> switch 2
  current shop: none switching to "the thing you wanted"...
````

# To check out

https://github.com/pry/pry-coolline
https://github.com/cldwalker/bond


# Menu of Shops in local apps
- [x] run rake shops in chosen local app
- [ ] display result of rake shops in a menu
  - how do we handle this? do we use letters? or does switch command remember state (which menu was displayed last)? ie, what does ```switch 1``` mean? 
- [ ] memoize results of rake shops in a hash with same keys as the apps have in config (I would put this in config). This is because running rake shops is slow enough to be annoying.
- [ ] add -r,--refresh option to switch command to tell it to get fresh data
- [ ] deploy apps with shopify_dev gem
  - [ ] metafieldseditor              richard@webifytechnology.com
  - [ ] morfars-metafields            richard@webifytechnology.com
  - [ ] red-pepper-shipping           richard@webifytechnology.com
  - [ ] shipping-lifemap-bioreagents  richard@webifytechnology.com
  - [ ] shipping-staging              richard@webifytechnology.com
