module Monomer.Widgets.Util.Misc where

import Control.Lens ((^.))
import Data.Maybe (fromMaybe)

import qualified Data.Map as M

import Monomer.Core
import Monomer.Event

import qualified Monomer.Lens as L

maxNumericValue :: (RealFloat a) => a
maxNumericValue = x where
  n = floatDigits x
  b = floatRadix x
  (_, u) = floatRange x
  x = encodeFloat (b^n - 1) (u - n)

pointInViewport :: Point -> WidgetInstance s e -> Bool
pointInViewport p inst = pointInRect p (_wiViewport inst)

getKeyStatus :: InputStatus -> KeyCode -> KeyStatus
getKeyStatus inputStatus code = status where
  keys = _ipsKeys inputStatus
  status = fromMaybe KeyReleased (M.lookup code keys)

isShortCutControl :: WidgetEnv s e -> KeyMod -> Bool
isShortCutControl wenv mod = isControl || isCommand where
  isControl = not (isMacOS wenv) && _kmLeftCtrl mod
  isCommand = isMacOS wenv && _kmLeftGUI mod

isClipboardCopy :: WidgetEnv s e -> SystemEvent -> Bool
isClipboardCopy wenv event = checkKeyboard event testFn where
  testFn mod code motion = isShortCutControl wenv mod && isKeyC code

isClipboardPaste :: WidgetEnv s e -> SystemEvent -> Bool
isClipboardPaste wenv event = checkKeyboard event testFn where
  testFn mod code motion = isShortCutControl wenv mod && isKeyV code

isIgnoreChildrenEvents :: WidgetRequest s -> Bool
isIgnoreChildrenEvents IgnoreChildrenEvents = True
isIgnoreChildrenEvents _ = False

isIgnoreParentEvents :: WidgetRequest s -> Bool
isIgnoreParentEvents IgnoreParentEvents = True
isIgnoreParentEvents _ = False

isMacOS :: WidgetEnv s e -> Bool
isMacOS wenv = _weOS wenv == "Mac OS X"

numberInBounds :: (Ord a, Num a) => Maybe a -> Maybe a -> a -> Bool
numberInBounds Nothing Nothing _ = True
numberInBounds (Just minVal) Nothing val = val >= minVal
numberInBounds Nothing (Just maxVal) val = val <= maxVal
numberInBounds (Just minVal) (Just maxVal) val = val >= minVal && val <= maxVal
