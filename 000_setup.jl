using Pkg           # load a Julia package, here, the package manager itself

Pkg.activate(".")   # activate an enviroment in the current folder 
Pkg.instantiate()   # download and install all required packages 


#=
To run this code, either press the 'run' button in the top right corner 
or select the above lines and press "Ctrl + Enter" (Win/Linux) / "Command + Enter" (MacOS).

Reminder: In Visual Studio Code, all commands can be searched via 
    the **command palette**. 

Shortcut: 
    - "Ctrl + Shift + P" (Win/Linux)  
    - "Shift + Command + P" (MacOS)
=#


#=
    More details about the package manager:

    Once you have a Julia REPL [*] open, you can also interact with the package manager 
    by pressing the "]" key. Here you can do the above steps simply by typing "activate ."
    and "instantiate". (Notice, you can use "Tab" to autocomplete in the REPL! Very useful.)

    [*] The Julia Terminal it is a "read–eval–print loop" short "REPL".
=#