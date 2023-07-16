import           Data.Bifunctor (first)
import           Data.Monoid (All)
import           System.Exit (exitSuccess)
import           System.IO (Handle, hPutStrLn)

import qualified Data.Map as M

import           Graphics.X11.ExtraTypes.XF86 -- xF86XK_* symbols
import           XMonad
import           XMonad.Actions.Submap (submap)
import           XMonad.Hooks.ManageDocks (AvoidStruts)
import           XMonad.Layout.Fullscreen (FullscreenFocus)
import           XMonad.Layout.IfMax (IfMax(IfMax))
import           XMonad.Layout.LayoutModifier (ModifiedLayout)
import           XMonad.Layout.LayoutScreens (FixedLayout, fixedLayout)
import           XMonad.Layout.MultiColumns (MultiCol, multiCol)
import           XMonad.Layout.PerScreen (PerScreen, ifWider)
import           XMonad.Layout.Renamed (Rename(Replace), renamed)
import           XMonad.Util.Rectangle (toRatio)
import           XMonad.Util.Run (spawnPipe)
import           XMonad.StackSet (RationalRect(RationalRect))

import qualified XMonad.Hooks.DynamicLog as DynamicLog
import qualified XMonad.Hooks.EwmhDesktops as EwhmDesktops
import qualified XMonad.Hooks.ManageDocks as ManageDocks
import qualified XMonad.Layout.Fullscreen as Fullscreen
import qualified XMonad.StackSet as SS

-- MAIN ------------------------------------------------------------------------

main :: IO ()
main = do
  xmobarPipe <- spawnPipe "xmobar"
  xmonad $ def { terminal           = "alacritty"
               , workspaces         = map show [1 .. 9 :: Int]
               , manageHook         = myManageHook
               , layoutHook         = myLayoutHook
               , startupHook        = myStartupHook
               , handleEventHook    = myHandleEventHook
               , logHook            = myLogHook xmobarPipe
               , modMask            = mod4Mask
               , borderWidth        = myBorderWidth
               , normalBorderColor  = arcDarkGray1
               , focusedBorderColor = arcDarkBlue
               , keys               = myKeys
               }

-- CONFIGURATION ---------------------------------------------------------------

lvl5Mask :: KeyMask
lvl5Mask = mod3Mask

myBorderWidth :: Dimension
myBorderWidth = 1

myManageHook :: ManageHook
myManageHook =
  Fullscreen.fullscreenManageHook
    <+> ManageDocks.manageDocks
    <+> manageHook def

myStartupHook :: X ()
myStartupHook = do
  ManageDocks.docksStartupHook
  EwhmDesktops.ewmhDesktopsStartup
  startupHook def

myHandleEventHook :: Event -> X All
myHandleEventHook =
  EwhmDesktops.ewmhDesktopsEventHook
    <> Fullscreen.fullscreenEventHook
    <> ManageDocks.docksEventHook
    <> handleEventHook def

myLogHook :: Handle -> X ()
myLogHook xmobarPipe = do
  EwhmDesktops.ewmhDesktopsLogHook
  DynamicLog.dynamicLogWithPP $ DynamicLog.xmobarPP
    { DynamicLog.ppOutput = hPutStrLn xmobarPipe
    , DynamicLog.ppTitle  = DynamicLog.xmobarColor arcDarkBlue ""
                            . DynamicLog.shorten 100
    , DynamicLog.ppSep    = " | "
    }

-- LAYOUTS ---------------------------------------------------------------------

-- Amount of horizontal space to make a 16:9 window on a 3440x1440 monitor
-- stdRatio * 3440 = (1440 - 24) * (16 / 9)
stdRatio :: Rational
stdRatio = 472 / 645

type ML = ModifiedLayout
type MyLayout = Choose Cols (Choose OneMain Full)

myLayoutHook :: ML FullscreenFocus (ML AvoidStruts MyLayout) Window
myLayoutHook = Fullscreen.fullscreenFocus $ ManageDocks.avoidStruts $
  cols ||| oneMain ||| Full

type OneMain = ML Rename (PerScreen WideMain Tall)
oneMain :: OneMain Window
oneMain = renamed [Replace "Main"] $ ifWider 3000 wideMain regularMain

type WideMain = IfMax FixedLayout Tall
wideMain :: WideMain Window
wideMain =
  IfMax 1 (fixedLayout [Rectangle 461 24 2518 1416]) (Tall 1 (3 / 100) stdRatio)

regularMain :: Tall Window
regularMain = Tall 1 (3 / 100) (1 / 2)

type Cols = ML Rename MultiCol
cols :: Cols Window
cols = renamed [Replace "Cols"] $ multiCol [] 1 (3 / 100) (-0.5)

-- KEYMAP ----------------------------------------------------------------------

myKeys :: XConfig Layout -> M.Map (ButtonMask, KeySym) (X ())
myKeys conf@XConfig { modMask = modM } = M.fromList $
  [ ((modM .|. shiftMask, xK_q     ), io exitSuccess)
  , ((modM .|. shiftMask, xK_r     ), restartXmonad)
  , ((modM .|. shiftMask, xK_l     ), lockSession)
  , ((modM              , xK_n     ), refresh)
  -- layout modification
  , ((modM              , xK_v     ), sendMessage NextLayout)
  , ((modM .|. shiftMask, xK_v     ), setLayout $ layoutHook conf)
  , ((modM              , xK_h     ), sendMessage Shrink)
  , ((modM              , xK_l     ), sendMessage Expand)
  , ((modM              , xK_comma ), sendMessage (IncMasterN 1))
  , ((modM              , xK_period), sendMessage (IncMasterN (-1)))
  -- changing focus
  , ((modM              , xK_j     ), windows SS.focusDown)
  , ((modM              , xK_k     ), windows SS.focusUp)
  , ((modM              , xK_m     ), windows SS.focusMaster)
  -- moving windows
  , ((modM .|. shiftMask, xK_j     ), windows SS.swapDown)
  , ((modM .|. shiftMask, xK_k     ), windows SS.swapUp)
  , ((modM              , xK_Return), windows SS.swapMaster)
  , ((modM              , xK_t     ), withFocused $ windows . SS.sink)
  , ((modM              , xK_f     ), withFocused $ windows . floatWindow)
  -- make a window fullscreen by making it floating and resizing it
  , ((modM              , xK_g     ), withFocused $ windows . fullscreenWindow)
  -- controlling notifications
  , ((modM              , xK_c     ), spawn dunstClose)
  , ((modM .|. shiftMask, xK_c     ), spawn dunstCloseAll)
  , ((modM              , xK_grave ), spawn dunstHistory)
  , ((modM .|. shiftMask, xK_period), spawn dunstContext)
  -- running and closing programs
  , ((modM              , xK_q     ), kill)
  , ((modM .|. shiftMask, xK_Return), spawn $ terminal conf)
  , ((modM              , xK_r     ), spawn rofi)
  , ((modM              , xK_o     ), submap . M.fromList $
      [ ((modM, xK_c), spawn "chatterino")
      , ((modM, xK_e), spawn "emacs")
      , ((modM, xK_f), spawn "firefox")
      , ((modM, xK_k), spawn "keepassxc")
      , ((modM, xK_s), spawn "spotify")
      , ((modM, xK_z), spawn "zathura")
      ])
  ]
  ++
  withCustom
  -- volume control
  [ ((0, xF86XK_AudioRaiseVolume ), spawn raiseVolume)
  , ((0, xF86XK_AudioLowerVolume ), spawn lowerVolume)
  , ((0, xF86XK_AudioMute        ), spawn toggleVolume)
  -- screen brightness control
  , ((0, xF86XK_MonBrightnessUp  ), spawn screenBrightnessUp)
  , ((0, xF86XK_MonBrightnessDown), spawn screenBrightnessDown)
  -- media keys
  , ((0, xF86XK_AudioPlay        ), spawn playerPlayPause)
  , ((0, xF86XK_AudioStop        ), spawn playerStop)
  , ((0, xF86XK_AudioNext        ), spawn playerNext)
  , ((0, xF86XK_AudioPrev        ), spawn playerPrev)
  ]
  ++
  -- switch to or move a window to a workspace
  withCustom
  [ ((modM .|. shft, key), windows $ f ws)
  | (ws, key) <- zip (workspaces conf) [xK_1 .. xK_9]
  , (f, shft) <- [(SS.greedyView, 0), (SS.shift, shiftMask)]
  ]
  ++
  -- switch to or move a window to a screen
  [ ((modM .|. shft, key), screenWorkspace ix >>= (`whenJust` (windows . f)))
  | (ix, key) <- zip [0..] [xK_w, xK_e]
  , (f, shft) <- [(SS.view, 0), (SS.shift, shiftMask)]
  ]

withCustom :: [((KeyMask, KeySym), X ())] -> [((KeyMask, KeySym), X ())]
withCustom ks = ks ++ map (first toCustomLayout) ks

toCustomLayout :: (KeyMask, KeySym) -> (KeyMask, KeySym)
toCustomLayout (mask, sym) =
  first (.|. mask) . M.findWithDefault (0, sym) sym $ customRemaps

customRemaps :: M.Map KeySym (KeyMask, KeySym)
customRemaps = M.fromList
  [ (xK_Up                  , (lvl5Mask, xK_e          ))
  , (xK_Down                , (lvl5Mask, xK_d          ))
  , (xK_Left                , (lvl5Mask, xK_s          ))
  , (xK_Right               , (lvl5Mask, xK_f          ))

  , (xK_F1                  , (lvl5Mask, xK_1          ))
  , (xK_F2                  , (lvl5Mask, xK_2          ))
  , (xK_F3                  , (lvl5Mask, xK_3          ))
  , (xK_F4                  , (lvl5Mask, xK_4          ))
  , (xK_F5                  , (lvl5Mask, xK_5          ))
  , (xK_F6                  , (lvl5Mask, xK_6          ))
  , (xK_F7                  , (lvl5Mask, xK_7          ))
  , (xK_F8                  , (lvl5Mask, xK_8          ))
  , (xK_F9                  , (lvl5Mask, xK_9          ))
  , (xK_F10                 , (lvl5Mask, xK_0          ))
  , (xK_F11                 , (lvl5Mask, xK_numbersign ))
  , (xK_F12                 , (lvl5Mask, xK_percent    ))

  , (xF86XK_AudioRaiseVolume, (lvl5Mask, xK_q          ))
  , (xF86XK_AudioLowerVolume, (lvl5Mask, xK_a          ))
  , (xF86XK_AudioMute       , (lvl5Mask, xK_z          ))
  , (xF86XK_AudioPrev       , (lvl5Mask, xK_x          ))
  , (xF86XK_AudioPlay       , (lvl5Mask, xK_c          ))
  , (xF86XK_AudioNext       , (lvl5Mask, xK_v          ))
  ]

-- CUSTOM ACTIONS --------------------------------------------------------------

floatWindow :: Window -> WindowSet -> WindowSet
floatWindow focused stackSet = SS.float focused rect stackSet
  where
    workspaceRect@(Rectangle _ _ wsWidth wsHeight) =
      screenRect $ SS.screenDetail $ SS.current stackSet
    width = min (1920 + 2 * myBorderWidth) wsWidth
    height = min (1080 + 2 * myBorderWidth) wsHeight
    x = (wsWidth - width) `div` 2
    y = (wsHeight - height) `div` 2
    targetRect = Rectangle (fromIntegral x) (fromIntegral y) width height
    rect = toRatio targetRect workspaceRect

fullscreenWindow :: Window -> WindowSet -> WindowSet
fullscreenWindow focused = SS.float focused (RationalRect 0 0 1 1)

-- CUSTOM COMMANDS -------------------------------------------------------------

rofi :: String
rofi = "rofi -modes combi,drun,run,ssh -show combi -combi-modes drun,run,ssh"

volumeCmd, raiseVolume, lowerVolume, toggleVolume :: String
volumeCmd = "amixer set Master "
raiseVolume = volumeCmd ++ "5%+"
lowerVolume = volumeCmd ++ "5%-"
toggleVolume = volumeCmd ++ "toggle"

screenBrightnessCmd, screenBrightnessUp, screenBrightnessDown :: String
screenBrightnessCmd = "~/.screen-brightness "
screenBrightnessUp = screenBrightnessCmd ++ "-i 10 -ny"
screenBrightnessDown = screenBrightnessCmd ++ "-d 10 -ny"

playerCmd :: String
playerCmd = "playerctl -p spotify "

playerPlayPause, playerStop, playerNext, playerPrev :: String
playerPlayPause = playerCmd ++ "play-pause"
playerStop = playerCmd ++ "stop"
playerNext = playerCmd ++ "next"
playerPrev = playerCmd ++ "previous"

dunstctlCmd :: String
dunstctlCmd = "dunstctl "

dunstClose, dunstCloseAll, dunstHistory, dunstContext :: String
dunstClose = dunstctlCmd ++ "close"
dunstCloseAll = dunstctlCmd ++ "close-all"
dunstHistory = dunstctlCmd ++ "history-pop"
dunstContext  = dunstctlCmd ++ "context"

lockSession :: X ()
lockSession = spawn "loginctl lock-session"

restartXmonad :: X ()
restartXmonad = spawn "xmonad --restart"

-- COLORS ----------------------------------------------------------------------

arcDarkBlue, arcDarkGray1, arcDarkGray2, arcDarkGray3, arcDarkGray4 :: String
arcDarkBlue  = "#5294e2"
arcDarkGray1 = "#383c4a"
arcDarkGray2 = "#404552"
arcDarkGray3 = "#4b5162"
arcDarkGray4 = "#7c818c"
