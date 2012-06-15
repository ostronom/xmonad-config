Config {
    font = "xft:terminus:pixelsize=14:antialias=true",
    bgColor = "#000000",
    fgColor = "#ffffff",
    position = Static { xpos = 0, ypos = 0, width = 1679, height = 16},
    lowerOnStart = True,
    commands = [
        Run Date "%a %b %_d %H:%M" "date" 10,
        Run StdinReader
    ],
    sepChar = "%",
    alignSep = "}{",
    template = "%StdinReader% }{ <fc=#FFFFCC>%date%</fc>"
}
