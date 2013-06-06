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