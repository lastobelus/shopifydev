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

pry-shopify
  Switch is an object defined in the global scope, that refers to Pry.switch
  there is a command, called switch which presents a menu and accepts numerical argument
  it is a command-wrapper of Pry.Switch

  So we can do

  `[1] pry(main)> switch`

  to present a menu of options and then

  `[1] pry(main)> switch 3`

  to choose one of them. This command just refers to methods on Pry.Switch in its process definition

  Or we can use tab completion to present the menu by invoking switch as a global object.

  ```
  [1] pry(main)> switch.m[TAB]
  switch.metafieldseditor switch.morfars-metafields
  [2] pry(main)> switch.mo[TAB]rfars-metafields
  ```

  to accomplish the same.

when you choose 


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
