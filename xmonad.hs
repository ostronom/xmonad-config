import System.IO
import System.Exit
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeys)
import qualified XMonad.StackSet as W
import qualified Data.Map as M

myTerminal = "/usr/bin/urxvt"

myWorkspaces = ["1:code", "2:web", "3:chat"] ++ map show [4..9]

-- Window rules
myManageHook = composeAll
    [ className =? "Chromium"      --> doShift "2:web"
    , className =? "Google-chrome" --> doShift "2:web"
    , className =? "pidgin"        --> doShift "3:chat"
    , isFullscreen                 --> (doF W.focusDown <+> doFullFloat)]

-- Layouts
myLayout = avoidStruts (
    Tall 1 (3/100) (1/2) |||
    Mirror (Tall 1 (3/100) (1/2)) |||
    tabbed shrinkText tabConfig |||
    Full |||
    spiral (6/7)) |||
    noBorders (fullscreenFull Full)

-- Colors && stuff
myNormalBorderColor  = "#7c7c7c"
myFocusedBorderColor = "#ffb6b0"

tabConfig = defaultTheme {
    activeBorderColor = "#7C7C7C",
    activeTextColor = "#CEFFAC",
    activeColor = "#000000",
    inactiveBorderColor = "#7C7C7C",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}

xmobarTitleColor = "#FFB6B0"
xmobarCurrentWorkspaceColor = "#CEFFAC"
myBorderWidth = 1

-- Keys
myModMask = mod4Mask
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- Start terminal
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- Launch dmenu via yeganesh
    , ((modMask, xK_p), spawn "exe=`dmenu_path | yeganesh` && eval \"exec $exe\"")

    -- Take screenshot
    , ((modMask .|. shiftMask, xK_p), spawn "screenshot")

    -- Close focused window
    , ((modMask .|. shiftMask, xK_c), kill)

    -- Cycle through layouts
    , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

    -- Refresh window
    , ((modMask, xK_n), refresh)

    -- Focus next window
    , ((modMask, xK_j), windows W.focusDown)

    -- Focus prev window
    , ((modMask, xK_k), windows W.focusUp)

    -- Shrink master
    , ((modMask, xK_h), sendMessage Shrink)

    -- Expand master
    , ((modMask, xK_l), sendMessage Expand)

    -- Tile window
    , ((modMask, xK_t), withFocused $ windows . W.sink)

    -- Restart
    , ((modMask, xK_q), restart "xmonad" True)
    ] ++
    -- Switch to workspace / move window to workspace
    [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

-- Focus follows mouse
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myStartupHook = return ()

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobar.hs"
    xmonad $ defaults {
        logHook = dynamicLogWithPP $ xmobarPP {
              ppOutput = hPutStrLn xmproc
            , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
            , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
            , ppSep = "   "}
        , manageHook = manageDocks <+> myManageHook
    }

defaults = defaultConfig {
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,
    keys               = myKeys,
    layoutHook         = smartBorders $ myLayout,
    manageHook         = myManageHook,
    startupHook        = myStartupHook
}
