# Begging
A simple script to make unemployed players beg peds for money using the third eye

# Description
This is my very first script written for FiveM, if the player is set as unemployed, they can use `/beg` to start begging, then third eye peds to ask for money.

# Dependencies
- QBCore
- ox_lib

# Installation Guide
1. Download the resource from Github
2. Drop the folder to your `resources` folder
4. Add `ensure begging` to your server.cfg file
5. Configure `config.lua` to set whatever distance, money and other parameters


# Adding to radial menu

If you want to add to your radial menu, add the following to your `qbx_radialmenu>config>client.lua` under `jobItem`:

```
unemployed = {
    {
        id = 'togglebegging',
        icon = 'sign-hanging',
        label = 'Beg for cash',
        event = 'begging:client:ToggleBegging'
    }
}
```


# Usage
- Make sure you are unemployed
- Use `/beg` to start begging
- After the cooldown, you are able to beg again.

# Credits
- MasiBall - https://github.com/MasiBall/mb_begging / Used as a starting point for this script
